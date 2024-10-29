{
  config,
  pkgs,
  ...
}: let
  tunnelid = builtins.readFile "${config.sops.secrets.TunnelName.path}";
  credentialsFile = builtins.readFile "${config.sops.secrets.CloudflareCred.path}";
  tunnelname = "billysh";
  tunneluser = "tank";
in {
  environment.systemPackages = with pkgs; [
    cloudflared
  ];

  systemd.services = {
    "cloudflared-tunnel-${tunnelname}" = {
      description = "Cloudflare Tunnel Service for ${tunnelname}";
      after = ["network-online.target" "systemd-resolved.service"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --config /home/${tunneluser}/.cloudflared/config.yml --no-autoupdate run --cred-file ${credentialsFile} ${tunnelid}";
        Restart = "always";
      };
    };
  };
}
