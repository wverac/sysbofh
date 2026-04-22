{
  config,
  pkgs,
  inputs,
  ...
}: {
  home.username = "wvera";
  home.homeDirectory = "/Users/wvera";

  home.packages = with pkgs; [
    starship
    inputs.nixvim.packages.${pkgs.stdenv.hostPlatform.system}.default
    git
    gh
    # vim
    gotop
    wget
    curl
    fastfetch
    # docker
    # docker-compose
    # ollama - managed by ollama-darwin module
    inputs.claude-code.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.default
    opencode
    bash
    sshuttle
    autossh
    alejandra
    iterm2
    firefox-bin
    brave
    shellcheck
    nmap
    iperf3
    ripgrep
    tree
    jq
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "William Vera";
      user.email = "wv@linux.com";
      init.defaultBranch = "main";
    };
  };

  programs.starship = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  news.display = "silent";

  imports = [
    ../../modules/home/fastfetch.nix
    # ../../modules/home/tmux.nix #FIX:wtf?
    ../../modules/home/darwin-tmux.nix
    ../../modules/home/bofhbash.nix
    # ../../modules/home/vim.nix #FIX: conflicts with nixvim
    ../../modules/home/cloudflare-darwin.nix
    ../../modules/home/ollama-darwin.nix
  ];

  # SOPS
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/Users/wvera/.config/sops/age/keys.txt";
  sops.secrets.cloudflareTunnelName = {};
  sops.secrets.cloudflareCredFile = {};
  sops.secrets.cloudflareConfigPath = {};
  sops.secrets.ollamaHost = {};
  sops.secrets.ollamaPort = {};
  sops.secrets.ollamaOrigins = {};

  services.ollama-darwin = {
    enable = true;
    hostFile = config.sops.secrets.ollamaHost.path;
    portFile = config.sops.secrets.ollamaPort.path;
    originsFile = config.sops.secrets.ollamaOrigins.path;
  };

  services.cloudflare-tunnel = {
    enable = true;
    tunnelName = config.sops.secrets.cloudflareTunnelName.path;
    credFile = config.sops.secrets.cloudflareCredFile.path;
    configPath = config.sops.secrets.cloudflareConfigPath.path;
  };

  home.stateVersion = "25.05";
}
