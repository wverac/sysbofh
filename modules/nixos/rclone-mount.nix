{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.rclone-mount;
in {
  options.services.rclone-mount = {
    enable = lib.mkEnableOption "rclone remote mount";

    remoteSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "Remote path file.";
    };

    mountPointSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "Local mount point file.";
    };

    configFile = lib.mkOption {
      type = lib.types.path;
      description = "Rclone configuration file.";
    };

    user = lib.mkOption {
      type = lib.types.str;
      description = "Service user.";
    };

    cacheMode = lib.mkOption {
      type = lib.types.enum ["off" "minimal" "writes" "full"];
      default = "full";
      description = "VFS cache mode.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "--vfs-cache-max-age=24h"
        "--vfs-read-chunk-size=64M"
        "--dir-cache-time=72h"
        "--poll-interval=15s"
      ];
      description = "Extra mount arguments.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.rclone pkgs.fuse];

    systemd.services.rclone-mount = {
      description = "rclone remote mount";
      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      path = [pkgs.coreutils pkgs.gawk pkgs.fuse pkgs.rclone];

      serviceConfig = {
        Type = "notify";
        ExecStartPre = pkgs.writeShellScript "rclone-mount-pre" ''
          MOUNTPOINT=$(cat ${cfg.mountPointSecretFile})
          if ${pkgs.util-linux}/bin/mountpoint -q "$MOUNTPOINT" 2>/dev/null; then
            ${pkgs.fuse}/bin/fusermount -uz "$MOUNTPOINT" || true
          fi
        '';
        ExecStart = pkgs.writeShellScript "rclone-mount-start" ''
          REMOTE=$(cat ${cfg.remoteSecretFile})
          MOUNTPOINT=$(cat ${cfg.mountPointSecretFile})
          mkdir -p "$MOUNTPOINT"
          chown ${cfg.user} "$MOUNTPOINT"
          exec ${pkgs.rclone}/bin/rclone mount \
            "$REMOTE" \
            "$MOUNTPOINT" \
            --config ${cfg.configFile} \
            --uid $(id -u ${cfg.user}) \
            --gid $(id -g ${cfg.user}) \
            --vfs-cache-mode=${cfg.cacheMode} \
            --allow-other \
            ${lib.concatStringsSep " " cfg.extraArgs}
        '';
        ExecStop = pkgs.writeShellScript "rclone-mount-stop" ''
          MOUNTPOINT=$(cat ${cfg.mountPointSecretFile})
          ${pkgs.fuse}/bin/fusermount -u "$MOUNTPOINT"
        '';
        Restart = "on-failure";
        RestartSec = 10;
      };
    };

    programs.fuse.userAllowOther = true;
  };
}
