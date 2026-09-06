{pkgs, ...}: let
  # Tailscale maintains its own routing table: peer /32s, advertised subnet
  # routes and both address families. Consulting it directly means these rules
  # never enumerate prefixes and pick up route changes on their own.
  tailscaleTable = 52;

  # Tailnet destinations have to resolve before Mullvad's catch-all, wherever
  # that lands, or they are sent into wg0-mullvad and dropped.
  rulePriority = 5207;

  # Tailscale marks its own transport with 0x80000 and installs rules at 5210
  # (main), 5230 (default) and 5250 (unreachable) to keep that traffic out of
  # any tunnel. Mullvad's catch-all only sits above those when it wins the
  # startup race; when it loses it lands at 32764/32765 instead and the marked
  # transport dies on 5250 for IPv6 and leaks out the physical link for IPv4.
  # Resolving it above 5210 makes the placement irrelevant.
  transportPriority = 5209;
  tailscaleFwmark = "0x80000/0xff0000";

  # Constant, not allocated: 0x6d6f6c65 is both the table id and the fwmark
  # Mullvad tags its own traffic with.
  mullvadTable = 1836018789;

  # Mullvad's own split-tunnel connmark. Its firewall carries a permanent
  # `ct mark 0x00000f41 accept` in both filter chains, so marking a packet is
  # the supported way past the kill switch. This is the mechanism behind
  # `mullvad-exclude`, applied per interface instead of per PID.
  mullvadMark = "0x00000f41";

  # The rule above cannot be relied on by itself: Mullvad adds its own rules
  # without a priority, so the kernel assigns each one just below the lowest
  # rule present at that moment. Once this service is up, restarting
  # mullvad-daemon therefore lands Mullvad's catch-all above rulePriority and
  # every tailnet packet is swallowed by the tunnel. Mirroring Tailscale's
  # routes into main sidesteps the race entirely, because Mullvad always
  # installs its own `lookup main suppress_prefixlength 0` above that catch-all
  # to keep the LAN reachable, so main is consulted first whichever order the
  # daemons started in. Longest-prefix match inside main also disambiguates a
  # CGNAT LAN on its own: a captive /16 beats the tailnet /10, a peer /32 beats
  # the /16. The proto tag is private to this module so only our own copies are
  # ever removed.
  mirrorProto = 194;

  lanRuleTag = "ts-coexist-lan";
  checkInterval = 15;
  fastInterval = 2;
  fastPasses = 5;

  # A table Mullvad does not manage. It only marks, never accepts, so it keeps
  # working across the firewall reprogramming Mullvad performs on every state
  # change. `oifname`/`iifname` match by name rather than ifindex, so the
  # ruleset loads even while tailscale0 does not exist yet.
  coexistRules = pkgs.writeText "ts-mullvad-coexist.nft" ''
    table inet ts-mullvad-coexist
    delete table inet ts-mullvad-coexist
    table inet ts-mullvad-coexist {
      chain output {
        type filter hook output priority mangle; policy accept;
        oifname "tailscale0" counter ct mark set ${mullvadMark}
      }
      chain input {
        type filter hook input priority mangle; policy accept;
        iifname "tailscale0" counter ct mark set ${mullvadMark}
      }
    }
  '';
in {
  systemd.services.mullvad-tailscale-coexist = {
    description = "Keep Tailscale reachable alongside Mullvad (tailnet routing, kill-switch bypass, CGNAT LAN ingress)";
    wantedBy = ["multi-user.target"];
    after = ["mullvad-daemon.service" "tailscaled.service"];
    wants = ["tailscaled.service"];
    path = [pkgs.iproute2 pkgs.nftables pkgs.gawk];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };

    script = ''
      # `suppress_prefixlength 0` ignores any default route in the Tailscale
      # table, so enabling an exit node later cannot silently pull every
      # connection out of the Mullvad tunnel.
      ensure_rule() {
        for family in -4 -6; do
          ip $family rule show pref ${toString rulePriority} 2>/dev/null | grep -q . \
            || ip $family rule add pref ${toString rulePriority} \
                 lookup ${toString tailscaleTable} suppress_prefixlength 0 2>/dev/null \
            || true

          ip $family rule show pref ${toString transportPriority} 2>/dev/null | grep -q . \
            || ip $family rule add pref ${toString transportPriority} \
                 fwmark ${tailscaleFwmark} lookup ${toString mullvadTable} 2>/dev/null \
            || true
        done
      }

      # Default routes are skipped for the same reason the rule carries
      # `suppress_prefixlength 0`: enabling an exit node later must not pull
      # every connection out of the Mullvad tunnel.
      ensure_mirror() {
        for family in -4 -6; do
          desired="$(ip $family route show table ${toString tailscaleTable} 2>/dev/null \
            | awk '$1 != "default" && $1 != "::/0" && $2 == "dev" { print $1, $3 }' \
            | sort -u)"
          current="$(ip $family route show table main proto ${toString mirrorProto} 2>/dev/null \
            | awk '$2 == "dev" { print $1, $3 }' \
            | sort -u)"

          printf '%s\n' "$desired" \
            | while read -r dest dev; do
                [ -n "$dest" ] || continue
                printf '%s\n' "$current" | grep -qxF "$dest $dev" \
                  || ip $family route add "$dest" dev "$dev" \
                       proto ${toString mirrorProto} table main 2>/dev/null || true
              done

          printf '%s\n' "$current" \
            | while read -r dest dev; do
                [ -n "$dest" ] || continue
                printf '%s\n' "$desired" | grep -qxF "$dest $dev" \
                  || ip $family route del "$dest" dev "$dev" \
                       proto ${toString mirrorProto} table main 2>/dev/null || true
              done
        done
      }

      ensure_marks() {
        nft list table inet ts-mullvad-coexist >/dev/null 2>&1 && return 0
        nft -f ${coexistRules}
      }

      # Tailscale's own ts-input chain drops every packet coming from
      # 100.64.0.0/10 on a non-tailscale interface. On a CGNAT-addressed LAN
      # (common on airport/hotel Wi-Fi) that kills all inbound LAN traffic,
      # including captive-portal replies. Punch a scoped exception per local
      # link subnet. "return" (not "accept") so the packet still goes through
      # the NixOS firewall instead of bypassing the whole input hook.
      ensure_lan_ingress() {
        nft list chain ip filter ts-input >/dev/null 2>&1 || return 0
        existing="$(nft -a list chain ip filter ts-input 2>/dev/null | grep '${lanRuleTag}' || true)"

        printf '%s\n' "$existing" \
          | sed -n 's|^[[:space:]]*iifname "\([^"]\+\)" ip saddr \([0-9./]\+\) .*# handle \([0-9]\+\)$|\1 \2 \3|p' \
          | while read -r dev subnet handle; do
              printf '%s\n' "$lan_links" | grep -qx "$subnet $dev" \
                || nft delete rule ip filter ts-input handle "$handle" 2>/dev/null || true
            done

        printf '%s\n' "$lan_links" \
          | while read -r subnet dev; do
              [ -n "$subnet" ] || continue
              printf '%s\n' "$existing" | grep -qF "iifname \"$dev\" ip saddr $subnet " \
                || nft insert rule ip filter ts-input iifname "$dev" ip saddr "$subnet" counter return comment '"${lanRuleTag}"' 2>/dev/null || true
            done
      }

      last_lan=""
      fast=0
      while :; do
        ensure_rule
        ensure_marks || true
        ensure_mirror || true

        # Only CGNAT-addressed local links matter here: on any other LAN the
        # tailnet range is unambiguous and ts-input never sees local traffic.
        lan_links="$(ip -4 route show proto kernel scope link 2>/dev/null \
          | sed -n 's|^\(100\.[0-9.]\+/[0-9]\+\) dev \([^ ]\+\).*|\1 \2|p' \
          | while read -r subnet dev; do [ "$dev" = "tailscale0" ] || echo "$subnet $dev"; done \
          | sort)"
        if [ "$lan_links" != "$last_lan" ]; then
          last_lan="$lan_links"
          fast=${toString fastPasses}
        fi

        ensure_lan_ingress || true

        # Tailscale rewrites ts-input a moment after a link change, so poll
        # faster for a short window right after the local subnets changed.
        if [ "$fast" -gt 0 ]; then
          fast=$((fast - 1))
          sleep ${toString fastInterval}
        else
          sleep ${toString checkInterval}
        fi
      done
    '';

    preStop = ''
      nft -a list chain ip filter ts-input 2>/dev/null \
        | sed -n 's|^.*${lanRuleTag}.*# handle \([0-9]\+\)$|\1|p' \
        | while read -r h; do
            nft delete rule ip filter ts-input handle "$h" 2>/dev/null || true
          done || true
      nft delete table inet ts-mullvad-coexist 2>/dev/null || true
      for family in -4 -6; do
        ip $family route flush table main proto ${toString mirrorProto} 2>/dev/null || true
        ip $family rule del pref ${toString rulePriority} 2>/dev/null || true
        ip $family rule del pref ${toString transportPriority} 2>/dev/null || true
      done
    '';
  };
}
