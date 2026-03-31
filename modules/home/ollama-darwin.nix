{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.services.ollama-darwin;
  logDir = "${config.home.homeDirectory}/Library/Logs/ollama";
in {
  options.services.ollama-darwin = {
    enable = lib.mkEnableOption "Ollama (Darwin)";
    hostFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the bind address";
    };
    portFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the bind port";
    };
    originsFile = lib.mkOption {
      type = lib.types.str;
      description = "Path to file containing the allowed CORS origins";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.ollama];

    home.activation.reloadOllama = lib.hm.dag.entryAfter ["linkGeneration"] ''
      plistName="org.nix-community.home.ollama-serve"
      plistPath="$HOME/Library/LaunchAgents/$plistName.plist"
      domainTarget="gui/$(id -u)"
      serviceTarget="$domainTarget/$plistName"
      hashFile="$HOME/.local/state/ollama-plist.md5"

      if [ -f "$plistPath" ]; then
        mkdir -p "$(dirname "$hashFile")"
        newHash=$(/sbin/md5 -q "$plistPath")
        oldHash=$(cat "$hashFile" 2>/dev/null || echo "none")

        if [ "$newHash" = "$oldHash" ]; then
          if ! /bin/launchctl print "$serviceTarget" &>/dev/null; then
            /bin/launchctl bootstrap "$domainTarget" "$plistPath" 2>/dev/null || true
            /bin/launchctl kickstart "$serviceTarget" 2>/dev/null || true
          fi
        else
          /bin/launchctl bootout "$serviceTarget" 2>/dev/null || true
          sleep 1
          /bin/launchctl bootstrap "$domainTarget" "$plistPath" 2>/dev/null || true
          /bin/launchctl kickstart -k "$serviceTarget" 2>/dev/null || true
        fi

        echo "$newHash" > "$hashFile"
      fi
    '';

    launchd.agents."ollama-serve" = {
      enable = true;
      config = {
        ProgramArguments = [
          "/bin/bash"
          "-c"
          ''
            # Wait for sops-nix to decrypt secrets
            for i in $(seq 1 30); do
              [ -f "${cfg.hostFile}" ] && [ -f "${cfg.portFile}" ] && [ -f "${cfg.originsFile}" ] && break
              sleep 1
            done
            OLLAMA_HOST="$(cat ${cfg.hostFile}):$(cat ${cfg.portFile})"
            export OLLAMA_HOST
            OLLAMA_ORIGINS="$(cat ${cfg.originsFile})"
            export OLLAMA_ORIGINS
            exec ${pkgs.ollama}/bin/ollama serve
          ''
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "${logDir}/ollama.log";
        StandardErrorPath = "${logDir}/ollama.err";
      };
    };
  };
}
