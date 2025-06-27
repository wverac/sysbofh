{
  pkgs,
  inputs,
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
  ];

  programs.git = {
    enable = true;
    userName = "William Vera";
    userEmail = "wv@linux.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # programs.zsh = {
  #   enable = true;
  #   shellAliases = {
  #     ll = "ls -larth";
  #     vim = "nvim";
  #   };
  # };

  programs.starship = {
    enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  imports = [
    ../../modules/home/fastfetch.nix
    ../../modules/home/tmux.nix
    ../../modules/home/bofhbash.nix
    # ../../modules/home/vim.nix # conflicts with nixvim
  ];

  home.stateVersion = "25.05";
}
