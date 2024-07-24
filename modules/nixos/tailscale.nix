{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    pkgs.tailscale
    pkgs.trayscale
  ];

  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = ["tailscale0"];
  networking.firewall.allowedUDPPorts = [config.services.tailscale.port];
  networking.firewall.allowedTCPPorts = [22];

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    after = ["network-pre.target" "tailscaled.service"];
    wants = ["network-pre.target" "tailscaled.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig.Type = "oneshot";

    script = with pkgs; ''
      # wait for tailscaled to settle
      sleep 2

      # check if we are already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then
        # ${tailscale}/bin/tailscale set --exit-node=$(cat ${config.sops.secrets.exitNode.path}) --exit-node-allow-lan-access=true
        ${tailscale}/bin/tailscale set --exit-node=$(${tailscale}/bin/tailscale exit-node suggest | grep ^Suggested | ${gawk}/bin/awk '{print $NF}') --exit-node-allow-lan-access=true
        exit 0
      fi

      # otherwise authenticate with tailscale
      # ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets.tailscaleKey.path}) --exit-node=$(cat ${config.sops.secrets.exitNode.path}) --exit-node-allow-lan-access=true
      ${tailscale}/bin/tailscale up -authkey $(cat ${config.sops.secrets.tailscaleKey.path}) --exit-node=$(${tailscale}/bin/tailscale exit-node suggest | grep ^Suggested | ${gawk}/bin/awk '{print $NF}') --exit-node-allow-lan-access=true

    '';
  };
}
