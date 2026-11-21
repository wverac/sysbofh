{
  lib,
  pkgs,
  ...
}: {
  # Enable Hyprland
  programs.hyprland.enable = true;
  # swaylock - commented for hyprlock migration
  #security.pam.services.swaylock = {};
  # hyprlock
  security.pam.services.hyprlock = {};
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  # Thunar
  # programs.thunar.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  # services.tumbler.enable = true; # Thumbnail support for images

  # programs.thunar.plugins = with pkgs; [
  #   thunar-archive-plugin
  #   thunar-volman
  # ];

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };

  environment.pathsToLink = ["/share/glycin-loaders"];

  environment.systemPackages = with pkgs;
    [
      nautilus
      sushi # space-bar file previews
      glycin-loaders # HEIF, JXL and SVG decoding for nautilus and sushi
      glycin-thumbnailer # HEIF/AVIF thumbnails in the nautilus grid
      loupe # image viewer with native HEIC support
      firefox
      alacritty
      waybar
      wttrbar
      rofi
      dunst
      awww
      # swaylock-effects/swayidle - commented for hyprlock/hypridle migration
      #swaylock-effects
      #swayidle
      hyprlock
      hypridle
      libnotify # notification in screen
      grimblast # Grab images from a Wayland compositor
      slurp # Select a region in a Wayland compositor
      wlogout
      zathura
      evince # gnome document viewer
      eog # Eye of GNOME
      xdg-utils
      google-chrome
      brave
      xclip
      wl-clipboard
      vscode
      code-cursor
      direnv # vscode depend
      meld
      networkmanager-openvpn
      networkmanagerapplet
      telegram-desktop
      feh
      vlc
      brightnessctl
      # cider # apple music client
      marktext
      obsidian
      imagemagick
      pro-office-calculator
      # sddm deps
      qt5.qtgraphicaleffects
      qt5.qtquickcontrols2
      # todoist
      todoist-electron
    ]
    # nixpkgs has no aarch64-linux build of these.
    ++ lib.optionals stdenv.hostPlatform.isx86_64 [
      slack
      zoom-us
      nomachine-client
    ];
}
