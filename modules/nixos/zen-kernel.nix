{
  pkgs,
  lib,
  ...
}: {
  # Enable the Zen kernel
  # boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_zen;
}
