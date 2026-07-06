{
  config,
  lib,
  pkgs,
  ...
}: let
  normalUsers = lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users);
  tailscaleOperator = lib.head (normalUsers ++ ["root"]);
  # Split DNS is only safe with systemd-resolved: tailscaled then registers
  # quad-100 as a per-link resolver on tailscale0 scoped to the tailnet domain
  # (Default Route: no), so ONLY *.ts.net queries go to MagicDNS and everything
  # else keeps using the system resolver (IVPN AntiTracker). Without resolved,
  # accept-dns=true would rewrite /etc/resolv.conf and send ALL DNS through
  # Tailscale — never do that, hence the conditional.
  # NOTE: this relies on the tailnet admin console NOT pushing global
  # nameservers ("Override local DNS" must stay off).
  acceptDNS =
    if config.services.resolved.enable
    then "true"
    else "false";
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
    # client-subnet traffic; DNS is split via systemd-resolved when available
    # (see acceptDNS above).
    extraUpFlags = [
      "--reset"
      "--accept-routes=true"
      "--accept-dns=${acceptDNS}"
      "--advertise-exit-node=false"
      "--operator=${tailscaleOperator}"
      "--shields-up=false"
      "--ssh=false"
    ];
  };

  # NOTE: the old tailscale-via-ivpn service (a boot-time `ip rule` at pref
  # 5205 forcing marked transport into table 51820) was removed: IVPN
  # re-inserts its own catch-all rule below any competing priority on every
  # reconnect, so the rule was silently wiped. The intent still holds without
  # it: IVPN's catch-all sends Tailscale's transport to remote endpoints into
  # the tunnel, and LAN endpoints exit directly via the
  # `main suppress_prefixlength 0` rule (IVPN "Allow LAN"). Tailnet-bound
  # traffic is handled by ivpn-tailscale-coexist.nix instead.

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
        --accept-dns=${acceptDNS} \
        --operator=${tailscaleOperator} \
        --shields-up=false \
        --ssh=false
    '';
  };
}
