{
  config,
  pkgs,
  ...
}: let
  lib = pkgs.lib;
  username = config.home.username;
  userConfigs = {
    bofh = {configFile = ../../modules/home/config/fastfetch/sysbofh.jsonc;};
    tank = {configFile = ../../modules/home/config/fastfetch/nixlab.jsonc;};
  };
  defaultConfig = {
    configFile = ../../modules/home/config/fastfetch/sysbofh.jsonc;
  };
  userConfig =
    if lib.hasAttr username userConfigs
    then lib.getAttr username userConfigs
    else defaultConfig;
in {
  home.packages = [pkgs.fastfetch];
  home.file.".config/fastfetch/config.jsonc".source = userConfig.configFile;
}
