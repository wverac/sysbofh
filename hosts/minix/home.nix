{ config, pkgs, ... }:

{
  home.username = "wvera";
  home.homeDirectory = "/Users/wvera";

  home.packages = with pkgs; [
    starship
  ];

  programs.git = {
    enable = true;
    userName = "William Vera";
    userEmail = "wv@linux.com";
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      ll = "ls -larth";
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

  home.stateVersion = "24.05";
}
