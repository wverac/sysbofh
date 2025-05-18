{pkgs, ...}: {
  # Enable Hyprland
  programs.hyprland.enable = true;
  # swaylock
  security.pam.services.swaylock = {};
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  # Thunar
  programs.thunar.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  programs.thunar.plugins = with pkgs.xfce; [
    thunar-archive-plugin
    thunar-volman
  ];

  environment.systemPackages = with pkgs; [
    alacritty
    waybar
    wttrbar
    rofi-wayland
    dunst
    swww
    swaylock-effects # replace swaylock
    swayidle
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
    maestral
    maestral-gui
    slack
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
    cider # apple music client
    zoom-us
    marktext
    obsidian
    imagemagick
    pro-office-calculator
    # sddm deps
    libsForQt5.qt5.qtgraphicaleffects
    libsForQt5.qt5.qtquickcontrols2
    # todoist
    todoist-electron
  ];
}
