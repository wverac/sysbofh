{lib, ...}: {
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
      buildMachinesFiles = [];
      useSubstitutes = true;
      listenHost = "127.0.0.1";
    };

    services.postgresql.identMap = lib.mkForce ''
      hydra-users postgres postgres
      hydra-users hydra hydra
      hydra-users hydra-www hydra
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
    };
  };
}
