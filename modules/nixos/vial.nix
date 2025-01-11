{pkgs, ...}: {
  # Vial support for setup my Corne v4 keyboard
  services.udev.packages = with pkgs; [
    vial
  ];
  environment.systemPackages = with pkgs; [
    vial
  ];
}
