{...}: {
  config = {
    # nix.settings.allowed-uris = [
    #   "github:"
    #   "git+https://github.com/"
    #   "git+ssh://github.com/"
    # ];
    services.hydra = {
      enable = true;
      hydraURL = "http://localhost:3000";
      notificationSender = "hydra@localhost";
      buildMachinesFiles = [];
      useSubstitutes = true;
    };
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [8888 3000];
      extraCommands = ''
        # Lab
        #  iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 3000
      '';
    };
    nix = {
      settings = {
        restrict-eval = false;
      };
    };
  };
}
