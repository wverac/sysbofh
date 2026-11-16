{config, ...}: let
  # Resolved over multicast DNS, so a machine that cannot reach it that way
  # needs an address here instead.
  queueRunner = "http://nixlab.local:50051";

  tokenSecret = "hydraBuilderToken";
in {
  # Since 26.11 the queue runner no longer reaches build machines over SSH.
  # Each machine that should build runs this agent and dials out over gRPC.
  config = {
    sops.secrets.${tokenSecret} = {
      group = "hydra"; # created by the upstream module
      mode = "0440";
    };

    # Replies to multicast name lookups arrive on this port, and the
    # interface varies per machine, so it is not scoped to one.
    networking.firewall.allowedUDPPorts = [5353];

    services.hydra-builder = {
      enable = true;
      queueRunnerAddr = queueRunner;
      authorizationFile = config.sops.secrets.${tokenSecret}.path;
    };
  };
}
