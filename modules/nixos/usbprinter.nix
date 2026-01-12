{pkgs, ...}: {
  # Printing service for Canon Pixma TS202 USB
  services.printing.enable = true;
  services.printing.drivers = [pkgs.cnijfilter2];
  environment.systemPackages = with pkgs; [cups];
}
