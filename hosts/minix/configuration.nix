{ config, pkgs, lib, inputs, ... }:

{
  imports = [ 
	inputs.home-manager.darwinModules.home-manager 
];

  nixpkgs.hostPlatform = "aarch64-darwin";

  networking.hostName = "minix";

  programs.zsh.enable = true;
  environment.shells = [ pkgs.zsh ];

  homebrew = {
    enable = false;
    taps = [ "homebrew/cask" ];
    casks = [ "iterm2" ];
  };

  # System-wide packages
  environment.systemPackages = with pkgs; [
    git
    vim
    gotop
    wget
    curl
  ];

  services.tailscale.enable = true;

  # macOS system tweaks
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllFiles = true;
    trackpad.Clicking = true;
  };

  # Home Manager Integration
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.wvera.home.homeDirectory = lib.mkForce "/Users/wvera";
  ids.gids.nixbld = 350;

  system.stateVersion = 4; # Keep this the same across updates
}

