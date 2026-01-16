{outputs, ...}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "tank";
  home.homeDirectory = "/home/tank";

  home.stateVersion = "25.05"; # Please read the comment before changing.
  imports = [
    ../../modules/home/lvim.nix
    ../../modules/home/tmux.nix
    ../../modules/home/vim.nix
    ../../modules/home/bofhbash.nix
    ../../modules/home/fastfetch.nix
  ];

  # Overlays
  nixpkgs = {
    overlays = [
      (import ../../overlays/onedark-nixlab.nix)
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
  programs.git.settings = {
    enable = true;
    user.name = "William Vera";
    user.email = "wv@linux.com";
    init.defaultBranch = "main";
  };

  # restart services on change
  systemd.user.startServices = "sd-switch";

  # notifications about home-manager news
  news.display = "silent";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
