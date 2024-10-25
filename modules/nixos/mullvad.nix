{pkgs, ...}: {
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.package = pkgs.mullvad-vpn;
  # systemd
  #services.resolved.enable = true;
}
