{pkgs, ...}: let
  # A filtered network needs a named server: `-f` ranks by ICMP ping, which
  # those networks usually drop. This is a fixed choice on purpose — the
  # manual tool in ~/Lab/FilteredNetworks picks a nearer one when it matters.
  fallbackLocation = "us-il.wg.ivpn.net";
  fallbackPort = "TCP:443";

  connectTimeout = "60";
  verifyUrl = "https://api.ivpn.net/v4/geo-lookup";
  verifyTimeout = "20";
  tailscaleSettle = "60";

  vpnReconnect = pkgs.writeShellApplication {
    name = "ivpn-reconnect";
    runtimeInputs = [pkgs.ivpn pkgs.curl pkgs.jq pkgs.coreutils];
    text = ''
      # Never trusts `ivpn status`: after a suspend the daemon reports
      # CONNECTED while the tunnel carries nothing. Only real traffic proves
      # one, so every attempt is checked against the API.
      verify() {
        curl -s --max-time ${verifyTimeout} ${verifyUrl} 2>/dev/null \
          | jq -e '.isIvpnServer == true' >/dev/null 2>&1
      }

      if verify; then
        echo "tunnel already carrying traffic"
        exit 0
      fi

      # No `ivpn disconnect` first: tearing the tunnel down kills every
      # long-lived connection through it — an rclone FUSE mount was left
      # hung on half-open sockets this way (2026-08-28). `ivpn connect`
      # replaces an existing tunnel on its own.
      if timeout ${connectTimeout} ivpn connect -p wg -f >/dev/null 2>&1 && verify; then
        echo "connected: native WireGuard"
        exit 0
      fi

      # Nothing native got through, so assume the network filters UDP.
      if timeout ${connectTimeout} ivpn connect -p wg -v2ray tcp \
           -port "${fallbackPort}" -l "${fallbackLocation}" >/dev/null 2>&1 && verify; then
        echo "connected: WireGuard over V2Ray ${fallbackPort}"
        exit 0
      fi

      echo "no transport worked; run ~/Lab/FilteredNetworks/bin/ivpn-connect"
      exit 1
    '';
  };

  tailscaleHeal = pkgs.writeShellApplication {
    name = "tailscale-heal";
    runtimeInputs = [pkgs.tailscale pkgs.jq pkgs.systemd pkgs.coreutils];
    text = ''
      # After a long suspend tailscaled keeps DERP alive but stops receiving
      # network maps, and never recovers on its own. Keys on Health, not on
      # .Self.Online — that field returns null on a healthy daemon.
      healthy() {
        tailscale status --json 2>/dev/null \
          | jq -e '.BackendState == "Running" and ((.Health // []) | length) == 0' \
            >/dev/null 2>&1
      }

      waited=0
      while [ "$waited" -lt ${tailscaleSettle} ]; do
        if healthy; then exit 0; fi
        sleep 5
        waited=$((waited + 5))
      done

      echo "tailscaled wedged after ''${waited}s; restarting"
      systemctl restart tailscaled
    '';
  };

  # Bringing the tunnel up is itself an interface event, so the VPN's own
  # interfaces are filtered out to avoid a loop.
  networkUpHook = pkgs.writeShellScript "vpn-on-network-up" ''
    [ "$2" = "up" ] || exit 0
    case "$1" in
      wgivpn | tun* | tailscale* | lo | docker* | virbr* | veth*) exit 0 ;;
    esac
    exec ${pkgs.systemd}/bin/systemctl start --no-block vpn-reconnect.service
  '';
in {
  environment.systemPackages = [vpnReconnect tailscaleHeal];

  systemd.services.vpn-reconnect = {
    description = "Restore the IVPN tunnel";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${vpnReconnect}/bin/ivpn-reconnect";
    };
  };

  # post-resume.target does not exist here; being both After and WantedBy the
  # sleep targets is the systemd idiom for running on wake.
  systemd.services.vpn-resume-heal = {
    description = "Repair VPN and Tailscale state after resume from sleep";
    after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${tailscaleHeal}/bin/tailscale-heal"
        # Through the unit, not the binary: systemd then serialises this
        # against the dispatcher, which fires on the same resume.
        "${pkgs.systemd}/bin/systemctl start --wait vpn-reconnect.service"
      ];
    };
  };

  networking.networkmanager.dispatcherScripts = [
    {
      type = "basic";
      source = networkUpHook;
    }
  ];
}
