{...}: {
  services.mullvad-vpn.enable = true;
  services.mullvad-vpn.gui.enable = true;
  # systemd
  #services.resolved.enable = true;
}
