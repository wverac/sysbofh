{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    cloudflared
  ];

  systemd.services = {
    "cloudflared-tunnel" = {
      description = "Cloudflare Tunnel Service";
      wantedBy = ["multi-user.target"];
      wants = ["network-online.target"];
      after = ["network-online.target" "systemd-resolved.service"];

      serviceConfig = {
        Restart = "always";
      };
      script = ''
        ${pkgs.cloudflared}/bin/cloudflared tunnel \
          --config $(cat ${config.sops.secrets."tunnelConfig".path}) \
          --no-autoupdate run \
          --cred-file $(cat ${config.sops.secrets."CloudflareCred".path}) \
          $(cat ${config.sops.secrets."TunnelName".path});
      '';
    };
  };
}
