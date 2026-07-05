{
  config,
  lib,
  pkgs,
  ...
}: let
  normalUsers = lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users);
  tailscaleOperator = lib.head (normalUsers ++ ["root"]);
in {
  assertions = [
    {
      assertion = lib.length normalUsers == 1;
      message = "The Tailscale module requires exactly one isNormalUser to select its operator.";
    }
  ];

  # services.tailscale already installs the Tailscale CLI.
  environment.systemPackages = [pkgs.trayscale];

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    openFirewall = true;
    authKeyFile = config.sops.secrets.tailscaleKey.path;

    # IVPN remains the default route. Tailscale only receives peer and
    # client-subnet traffic, and does not manage system DNS.
    extraUpFlags = [
      "--reset"
      "--accept-routes=true"
      "--accept-dns=false"
      "--advertise-exit-node=false"
      "--operator=${tailscaleOperator}"
      "--shields-up=true"
      "--ssh=false"
    ];
  };

  # Tailscale marks its transport sockets with 0x80000 and normally routes
  # them through the main table. Override that lookup so the transport is
  # carried inside IVPN's WireGuard tunnel (routing table 51820).
  systemd.services.tailscale-via-ivpn = {
    description = "Route Tailscale transport through IVPN";
    wantedBy = ["multi-user.target"];
    requires = ["ivpn-service.service"];
    after = ["ivpn-service.service"];
    before = ["tailscaled.service"];
    path = [pkgs.iproute2];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      while ip -4 rule del pref 5205 2>/dev/null; do :; done
      ip -4 rule add pref 5205 fwmark 0x80000/0xff0000 lookup 51820
    '';

    preStop = ''
      ip -4 rule del pref 5205 2>/dev/null || true
    '';
  };

  # The hostname is encrypted with SOPS and therefore must be read at runtime.
  # Apply all persistent client-only settings here as well, including clearing
  # any exit-node preference left in tailscaled.state.
  systemd.services.tailscale-configure = {
    description = "Apply Tailscale client settings";
    wantedBy = ["multi-user.target"];
    requires = ["tailscaled.service"];
    wants = ["tailscaled-autoconnect.service"];
    after = [
      "sops-nix.service"
      "tailscaled.service"
      "tailscaled-autoconnect.service"
    ];

    serviceConfig.Type = "oneshot";

    script = ''
      tailscale_host="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${config.sops.secrets.tailscaleHost.path})"
      if [ -z "$tailscale_host" ]; then
        echo "tailscaleHost must not be empty" >&2
        exit 1
      fi

      ${pkgs.tailscale}/bin/tailscale set \
        --hostname="$tailscale_host" \
        --exit-node= \
        --advertise-exit-node=false \
        --advertise-routes= \
        --accept-routes=true \
        --accept-dns=false \
        --operator=${tailscaleOperator} \
        --shields-up=true \
        --ssh=false
    '';
  };
}
