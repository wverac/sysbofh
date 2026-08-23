{
  config,
  lib,
  pkgs,
  ...
}: let
  tailnetRange = "100.64.0.0/10";
  magicDNS = "100.100.100.100";
  ivpnTableBase = 51820;
  checkInterval = 15;
  fastInterval = 2;
  fastPasses = 5;
  lanRuleTag = "ts-coexist-lan";
in {
  systemd.services.ivpn-tailscale-coexist = {
    description = "Keep Tailscale usable alongside IVPN (tailnet route, MagicDNS pinhole, anti-leak guard)";
    wantedBy = ["multi-user.target"];
    after = ["ivpn-service.service" "tailscaled.service"];
    wants = ["tailscaled.service"];
    path = [pkgs.iproute2 pkgs.nftables];

    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
    };

    script = ''
      # Recreate the egress guard table if it is missing. Returns 0 when it was
      # (re)built, so the caller knows the lan_bypass set has to be repopulated.
      ensure_table() {
        nft list table ip ts-coexist >/dev/null 2>&1 && return 1
        nft add table ip ts-coexist
        nft 'add set ip ts-coexist lan_bypass { type ipv4_addr; flags interval; }'
        nft 'add chain ip ts-coexist guard { type filter hook output priority filter + 10; policy accept; }'
        nft add rule ip ts-coexist guard ip daddr @lan_bypass counter accept
        nft add rule ip ts-coexist guard ip daddr ${tailnetRange} oifname != tailscale0 oifname != lo counter drop
        return 0
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

      nft delete table ip ts-coexist 2>/dev/null || true
      ensure_table || true

      last_lan=""
      fast=0
      while :; do
        ensure_table && last_lan=""

        lan_links="$(ip -4 route show proto kernel scope link 2>/dev/null \
          | sed -n 's|^\(100\.[0-9.]\+/[0-9]\+\) dev \([^ ]\+\).*|\1 \2|p' \
          | while read -r subnet dev; do [ "$dev" = "tailscale0" ] || echo "$subnet $dev"; done \
          | sort)"
        if [ "$lan_links" != "$last_lan" ]; then
          nft flush set ip ts-coexist lan_bypass 2>/dev/null || true
          printf '%s\n' "$lan_links" \
            | while read -r subnet dev; do
                [ -n "$subnet" ] || continue
                nft add element ip ts-coexist lan_bypass "{ $subnet }" 2>/dev/null || true
              done
          last_lan="$lan_links"
          fast=${toString fastPasses}
        fi

        ensure_lan_ingress || true

        current_table="$(ip -4 rule show | sed -n 's/.*not from all fwmark 0x[0-9a-f]\+ lookup \([0-9]\+\).*/\1/p' | head -n1)"

        ip -4 route show table all 2>/dev/null \
          | sed -n 's|^${tailnetRange} dev tailscale0 table \([0-9]\+\).*|\1|p' \
          | while read -r t; do
              if [ "$t" -ge ${toString ivpnTableBase} ] && [ "$t" != "$current_table" ]; then
                ip -4 route del ${tailnetRange} dev tailscale0 table "$t" 2>/dev/null || true
              fi
            done || true

        if [ -n "$current_table" ] && ip -4 link show tailscale0 >/dev/null 2>&1; then
          ip -4 route show table "$current_table" 2>/dev/null | grep -q '^${tailnetRange} ' \
            || ip -4 route replace ${tailnetRange} dev tailscale0 table "$current_table" 2>/dev/null \
            || true
        fi

        if nft list chain ip filter IVPN-OUT-DNS >/dev/null 2>&1; then
          nft list chain ip filter IVPN-OUT-DNS | grep -q '${magicDNS}' || {
            nft insert rule ip filter IVPN-OUT-DNS ip daddr ${magicDNS} udp dport 53 accept 2>/dev/null || true
            nft insert rule ip filter IVPN-OUT-DNS ip daddr ${magicDNS} tcp dport 53 accept 2>/dev/null || true
          }
        fi

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
      nft delete table ip ts-coexist 2>/dev/null || true
      ip -4 route show table all 2>/dev/null \
        | sed -n 's|^${tailnetRange} dev tailscale0 table \([0-9]\+\).*|\1|p' \
        | while read -r t; do
            if [ "$t" -ge ${toString ivpnTableBase} ]; then
              ip -4 route del ${tailnetRange} dev tailscale0 table "$t" 2>/dev/null || true
            fi
          done || true
    '';
  };
}
