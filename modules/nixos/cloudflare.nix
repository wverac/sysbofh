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
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target" "systemd-resolved.service"];

      serviceConfig = {
        Restart = "always";
      };
      script = ''
        ${pkgs.cloudflared}/bin/cloudflared tunnel --config /home/${tunneluser}/.cloudflared/config.yml --no-autoupdate run --cred-file $(cat ${config.sops.secrets."CloudflareCred".path}) $(cat ${config.sops.secrets."TunnelName".path});
      '';
    };
  };
}
