{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.cloudflare-tunnel;
  logDir = "${config.home.homeDirectory}/Library/Logs/cloudflared";
in {
  options.services.cloudflare-tunnel = {
    enable = lib.mkEnableOption "Cloudflare Tunnel";
    tunnelName = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the Cloudflare Tunnel name";
    };
    credFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the credentials.json path";
    };
    configPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the cloudflared config file path";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.cloudflared];

    home.activation.reloadCloudflared = lib.hm.dag.entryAfter ["linkGeneration"] ''
      plistName="org.nix-community.home.cloudflared-tunnel"
      plistPath="$HOME/Library/LaunchAgents/$plistName.plist"
      if [ -f "$plistPath" ]; then
        /bin/launchctl bootout "gui/$(id -u)/$plistName" 2>/dev/null || true
        /bin/launchctl bootstrap "gui/$(id -u)" "$plistPath"
      fi
    '';

    launchd.agents."cloudflared-tunnel" = {
      enable = true;
      config = {
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            CONFIG_PATH=$(cat ${cfg.configPath})
            CRED_FILE=$(cat ${cfg.credFile})
            ${pkgs.cloudflared}/bin/cloudflared tunnel \
              --config "$CONFIG_PATH" \
              --no-autoupdate \
              run \
              --cred-file "$CRED_FILE"
          ''
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "${logDir}/cloudflared.log";
        StandardErrorPath = "${logDir}/cloudflared.err";
      };
    };
  };
}
