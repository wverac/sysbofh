{
  inputs,
  outputs,
}: let
  inherit (inputs.nixpkgs) lib;

  getHomeCfg = _: cfg: cfg.config.home.activationPackage;
  getConfigTopLevel = _: cfg: cfg.config.system.build.toplevel;

  # Filter out darwin configurations (Hydra only has Linux builders)
  #linuxHomes =
  #  lib.filterAttrs
  #  (_: cfg: cfg.pkgs.stdenv.hostPlatform.isLinux)
  #  outputs.homeConfigurations;

  # Hydra only has x86_64-linux builders
  #isBuildable = _: cfg: cfg.pkgs.stdenv.hostPlatform.system == "x86_64-linux";

  # Builders for aarch64-linux and aarch64-darwin are being added, so every
  # system is offered to the queue runner.
  isBuildable = _: _: true;
in {
  hosts = lib.mapAttrs getConfigTopLevel (lib.filterAttrs isBuildable outputs.nixosConfigurations);
  homes = lib.mapAttrs getHomeCfg (lib.filterAttrs isBuildable outputs.homeConfigurations);
}
