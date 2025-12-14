{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    protonvpn-gui
    wireguard-tools
  ];

  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
  };
}
