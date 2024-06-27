{outputs, ...}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "tank";
  home.homeDirectory = "/home/tank";

  home.stateVersion = "24.05"; # Please read the comment before changing.
  imports = [
    ../../modules/home/lvim.nix
    ../../modules/home/tmux.nix
    ../../modules/home/vim.nix
  ];

  nixpkgs = {
    overlays = [
      # no pgks yet
      # outputs.overlays.additions
      outputs.overlays.modifications
      # outputs.overlays.stable-packages # we living in the edge!
    ];
    config = {
      allowUnfree = true;
    };
  };

  # dotfiles
  home.file = {
    #".config/neofetch/config.conf".source = ../../modules/home/config/neofetch/config.conf;
  };

  # Packages that should be installed to the user profile.
  home.packages = [
    #neofetch
  ];
  #

  # My bash alias
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -latrh";
      #vim = "lvim";
    };
  };
  # Basic configuration of git
  programs.git = {
    enable = true;
    userName = "William Vera";
    userEmail = "wv@linux.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # restart services on change
  systemd.user.startServices = "sd-switch";

  # notifications about home-manager news
  news.display = "silent";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
