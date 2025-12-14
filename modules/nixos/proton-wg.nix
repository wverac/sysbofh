{
  lib,
  pkgs,
  ...
}: let
  iface = "protonvpn";
  cfgFile = "/etc/protonvpn/wg.conf";
in {
  # wg-quick interface
  networking.wg-quick.interfaces.${iface} = {
    configFile = cfgFile;
  };

  # Optional debugging tools
  environment.systemPackages = with pkgs; [
    wireguard-tools
    iptables
    iproute2
    curl
  ];

  # Assertions: config exists + full-tunnel AllowedIPs
  assertions = [
    {
      assertion = builtins.pathExists cfgFile;
      message = "ProtonVPN WireGuard config missing: ${cfgFile}";
    }
    {
      assertion = let
        contents = builtins.readFile cfgFile;
      in
        (builtins.match ".*AllowedIPs *= *0\\.0\\.0\\.0/0, *::/0.*" contents) != null;
      message = ''
        ${cfgFile} must contain:
          AllowedIPs = 0.0.0.0/0, ::/0
      '';
    }
  ];

  systemd.services."wg-quick-${iface}" = {
    after = lib.mkAfter ["network-online.target"];
    wants = lib.mkAfter ["network-online.target"];
  };
}
