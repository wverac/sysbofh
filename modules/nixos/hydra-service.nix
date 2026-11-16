{
  config,
  lib,
  ...
}: {
  config = {
    nix.settings = {
      allowed-uris = [
        "github:"
        "git+https://github.com/"
        "git+ssh://github.com/"
        "git+ssh://github.com/wverac/"
        "https://github.com/NixOS/"
      ];
      restrict-eval = false;
    };

    services.hydra = {
      enable = true;
      hydraURL = "http://localhost:3000";
      notificationSender = "hydra@localhost";
      useSubstitutes = true;
      listenHost = "127.0.0.1";
      #queueRunner.grpc.address = "[::]";
      #queueRunner.settings.tokenPaths = [config.sops.secrets.hydraBuilderToken.path];
    };

    #Kept here so the module stands on its own.
    #sops.secrets.hydraBuilderToken = {
    #  group = "hydra"; # created by the upstream module
    #  mode = "0440";
    #};

    # Since 26.11 the queue runner no longer builds, this host runs its own agent.
    services.hydra-builder = {
      enable = true;
      queueRunnerAddr = "http://[::1]:${toString config.services.hydra.queueRunner.grpc.port}";
    };

    services.postgresql.identMap = lib.mkForce ''
      hydra-users postgres postgres
      hydra-users hydra hydra
      hydra-users hydra-www hydra
      hydra-users hydra-ws hydra
      hydra-users hydra-queue-runner hydra
    '';

    services.postgresql.authentication = lib.mkForce ''
      local all all peer map=hydra-users
      host all all 127.0.0.1/32 scram-sha-256
      host all all ::1/128 scram-sha-256
    '';

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [];
      #interfaces."enp1s0" = {
      #  allowedTCPPorts = [50051];
      #  # Multicast name resolution, so this host is reachable by name.
      #  allowedUDPPorts = [5353];
      #};
    };
  };
}
