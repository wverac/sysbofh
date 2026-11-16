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
      queueRunner.grpc.address = "[::]";
      queueRunner.settings.tokenPaths = [config.sops.secrets.hydraBuilderToken.path];
    };

    services.hydra-builder = {
      enable = true;
      queueRunnerAddr = "http://nixlab.local:50051";
      authorizationFile = config.sops.secrets.hydraBuilderToken.path;
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
      interfaces."enp1s0".allowedTCPPorts = [50051];
    };
  };
}
