{pkgs, ...}: {
  services.ivpn.enable = true;
  environment.systemPackages = [pkgs.ivpn-ui];
}
