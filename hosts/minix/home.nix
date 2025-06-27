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
    vim
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

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -larth";
      vim = "nvim";
    };
  };

  programs.starship = {
    enable = true;
  };

  imports = [
    ../../modules/home/fastfetch.nix
    ../../modules/home/tmux.nix
    ../../modules/home/vim.nix
  ];

  home.stateVersion = "25.05";
}
