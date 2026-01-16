{
  inputs,
  outputs,
}: let
  inherit (inputs.nixpkgs) lib;

  getHomeCfg = _: cfg: cfg.config.home.activationPackage;
  getConfigTopLevel = _: cfg: cfg.config.system.build.toplevel;

  # Filter out darwin configurations (Hydra only has Linux builders)
  linuxHomes =
    lib.filterAttrs
    (_: cfg: cfg.pkgs.stdenv.hostPlatform.isLinux)
    outputs.homeConfigurations;
in {
  hosts = lib.mapAttrs getConfigTopLevel outputs.nixosConfigurations;
  homes = lib.mapAttrs getHomeCfg linuxHomes;
}
