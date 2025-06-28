{
  pkgs,
  inputs,
  lib,
  ...
}: {
  home.username = "wvera";
  home.homeDirectory = "/Users/wvera";

  home.packages = with pkgs; [
    starship
    inputs.nixvim.packages.${pkgs.system}.default
    git
    # vim #FIX: conflicts with nixvim
    gotop
    wget
    curl
    fastfetch
    docker
    docker-compose
    ollama
    claude-code
    bash
    tailscale
    goose-cli
    sshuttle
  ];

  programs.git = {
    enable = true;
    userName = "William Vera";
    userEmail = "wv@linux.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cat = "bat --paging=never";
      lcat = "bat --style=plain --paging=never";
      ls = lib.mkForce "lsd";
      ll = lib.mkForce "lsd -latrh";
      vim = lib.mkForce "nvim";
    };
    bashrcExtra = ''
      # Use modern bash features with Nix bash
      eval "$(fzf --bash)"
    '';
  };

  programs.starship = {
    enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  news.display = "silent";

  # Tailscale CLI management script
  home.file.".local/bin/tailscale-macos" = {
    source = ../../modules/home/config/scripts/tailscale-macos.sh;
    executable = true;
  };

  imports = [
    ../../modules/home/fastfetch.nix
    ../../modules/home/tmux.nix
    ../../modules/home/bofhbash.nix
    # ../../modules/home/vim.nix #FIX: conflicts with nixvim
  ];

  home.stateVersion = "25.05";
}
