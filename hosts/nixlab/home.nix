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
    ../../modules/home/bofhbash.nix
  ];

  # Overlays
  nixpkgs = {
    overlays = [
      (self: super: {
        utillinux = super.util-linux;
      })
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
