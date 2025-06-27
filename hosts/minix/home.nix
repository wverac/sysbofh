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
    # vim # removed - conflicts with nixvim
    gotop
    wget
    curl
    fastfetch
    docker
    docker-compose
    ollama
    claude-code
    bash # Modern bash from Nix
    tailscale
    goose-cli
  ];

  programs.git = {
    enable = true;
    userName = "William Vera";
    userEmail = "wv@linux.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # Use modern bash from Nix on macOS
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Disable home-manager news notifications
  news.display = "silent";

  imports = [
    ../../modules/home/fastfetch.nix
    ../../modules/home/tmux.nix
    ../../modules/home/bofhbash.nix
    # ../../modules/home/vim.nix # conflicts with nixvim
  ];

  home.stateVersion = "25.05";
}
