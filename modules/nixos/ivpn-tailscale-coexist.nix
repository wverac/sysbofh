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
      nft delete table ip ts-coexist 2>/dev/null || true
      nft add table ip ts-coexist
      nft 'add chain ip ts-coexist guard { type filter hook output priority filter + 10; policy accept; }'
      nft add rule ip ts-coexist guard ip daddr ${tailnetRange} oifname != tailscale0 oifname != lo counter drop

      while :; do
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

        sleep ${toString checkInterval}
      done
    '';

    preStop = ''
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
