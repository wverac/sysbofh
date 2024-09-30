{pkgs, ...}: {
  # hardware setup for my system76 Lemur Pro 13
  hardware.system76 = {
    # this enabled: power-daemon, kernel-modules, firmware-daemon
    enableAll = true;
  };
  environment.systemPackages = with pkgs; [
    system76-keyboard-configurator
    system76-firmware
    linuxKernel.packages.linux_zen.system76
    linuxKernel.packages.linux_zen.system76-power
  ];
}
