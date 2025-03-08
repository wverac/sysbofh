{
  config,
  pkgs,
  ...
}: let
  tunnelname = "billysh";
  tunneluser = "tank";
in {
  environment.systemPackages = with pkgs; [
    cloudflared
  ];

  systemd.services = {
    "cloudflared-tunnel-${tunnelname}" = {
      description = "Cloudflare Tunnel Service for ${tunnelname}";
      after = ["systemd-resolved.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        Restart = "always";
      };
      script = ''
        ${pkgs.cloudflared}/bin/cloudflared tunnel --config /home/${tunneluser}/.cloudflared/config.yml --no-autoupdate run --cred-file $(cat ${config.sops.secrets."CloudflareCred".path}) $(cat ${config.sops.secrets."TunnelName".path});
      '';
    };
  };
}
