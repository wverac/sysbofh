{...}: {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "bofh";
  home.homeDirectory = "/home/bofh";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  imports = [
    ../../modules/home/mimedefault.nix
    ../../modules/home/gtktheme.nix
    ../../modules/home/dotfiles.nix
    ../../modules/home/avizo.nix
    ../../modules/home/lvim.nix
    ../../modules/home/vim.nix
    ../../modules/home/tmux.nix
    ../../modules/home/bofhbash.nix
    ../../modules/home/neovim.nix
  ];

  # dotfiles
  home.file = {
    #".config/neofetch/config.conf".source = ../../modules/home/config/neofetch/config.conf;
  };

  # Packages that should be installed to the user profile.
  home.packages = [
    #fastfetch
  ];
  #

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
