{
  inputs,
  outputs,
}: let
  inherit (inputs.nixpkgs) lib;
  getHomeCfg = _: cfg: cfg.config.home.activationPackage;
  getConfigTopLevel = _: cfg: cfg.config.system.build.toplevel;
in {
  hosts = lib.mapAttrs getConfigTopLevel outputs.nixosConfigurations;
  homes = lib.mapAttrs getHomeCfg outputs.homeConfigurations;
}
