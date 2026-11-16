{pkgs, ...}: let
  # cloudflared runs as a systemd service, so its cgroup path is fixed. nft
  # resolves that path to a cgroup id when the ruleset loads, and systemd
  # recreates the cgroup on every unit start, so the table has to be reloaded
  # from ExecStartPost rather than from a long-lived helper.
  unit = "cloudflared-tunnel";
  cgroupPath = "system.slice/${unit}.service";
  cgroupLevel = 2;

  # Constant, not allocated: the fwmark Mullvad tags its own traffic with. Its
  # catch-all rule reads `not from all fwmark 0x6d6f6c65 lookup <tunnel
  # table>`, so a packet carrying it skips the tunnel table and falls through
  # to main and the physical link.
  mullvadFwmark = "0x6d6f6c65";

  # Mullvad's own split-tunnel connmark. Its firewall accepts it in every
  # filter chain and its nat chain masquerades it on any non-tunnel interface,
  # so marking a packet is the supported way past the kill switch. This is the
  # mechanism behind `mullvad-exclude`, applied per cgroup v2 path instead of
  # per PID through the net_cls hierarchy.
  mullvadMark = "0x00000f41";

  table = "cf-mullvad-coexist";

  # `route` so the changed mark re-runs the routing decision for the packet.
  # The priority is deliberate: Tailscale installs `ct state new meta mark &
  # 0xff0000 != 0 ct mark set mark and 0xff0000` in the ip/ip6 mangle OUTPUT
  # chains (priority mangle). That runs after Mullvad's own mangle chain and
  # overwrites the 0xf41 connmark with the fwmark's 0xff0000 bits, so the
  # masquerade never matches and the packet leaves the physical link with the
  # tunnel address. It is also why `mullvad-exclude` is broken on hosts running
  # both daemons. Landing one step later keeps the connmark intact.
  coexistRules = pkgs.writeText "${table}.nft" ''
    table inet ${table}
    delete table inet ${table}
    table inet ${table} {
      chain output {
        type route hook output priority mangle + 1; policy accept;
        socket cgroupv2 level ${toString cgroupLevel} "${cgroupPath}" counter ct mark set ${mullvadMark} meta mark set ${mullvadFwmark}
      }
    }
  '';
in {
  # Both steps are non-fatal: this table only marks, never accepts, so a
  # failure here must not take the tunnel down with it.
  systemd.services.${unit}.serviceConfig = {
    ExecStartPost = "-${pkgs.nftables}/bin/nft -f ${coexistRules}";
    ExecStopPost = "-${pkgs.nftables}/bin/nft delete table inet ${table}";
  };
}
