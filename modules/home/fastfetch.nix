{
  config,
  pkgs,
  ...
}: let
  username = config.home.username;
  userConfigs = {
    bofh = ../../modules/home/config/fastfetch/sysbofh.jsonc;
    tank = ../../modules/home/config/fastfetch/tank.jsonc;
    # Add more users as needed
  };
  defaultConfigFile = ../../modules/home/config/fastfetch/sysbofh.jsonc;
  configFile = builtins.getAttr username userConfigs or defaultConfigFile;
in {
  home.packages = [pkgs.fastfetch];
  home.file.".config/fastfetch/config.jsonc".source = configFile;
}
