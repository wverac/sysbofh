{
  config,
  pkgs,
  hostname ? "",
  ...
}: let
  lib = pkgs.lib;
  username = config.home.username;
  hostConfigs = {
    hydra = {
      configFile = ../../modules/home/config/fastfetch/hydra.jsonc;
      logoFile = ../../modules/home/config/fastfetch/hydra-logo.txt;
    };
  };
  userConfigs = {
    bofh = {configFile = ../../modules/home/config/fastfetch/sysbofh.jsonc;};
    tank = {configFile = ../../modules/home/config/fastfetch/nixlab.jsonc;};
  };
  defaultConfig = {
    configFile = ../../modules/home/config/fastfetch/sysbofh.jsonc;
  };
  userConfig =
    if lib.hasAttr hostname hostConfigs
    then lib.getAttr hostname hostConfigs
    else if lib.hasAttr username userConfigs
    then lib.getAttr username userConfigs
    else defaultConfig;
in {
  home.packages = [pkgs.fastfetch];
  home.file.".config/fastfetch/config.jsonc".source = userConfig.configFile;
  home.file.".config/fastfetch/logo.txt" = lib.mkIf (userConfig ? logoFile) {
    source = userConfig.logoFile;
  };
}
