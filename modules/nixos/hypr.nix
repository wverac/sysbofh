{pkgs, ...}: let
  # Waybar 0.15.0 still sends Hyprland's legacy workspace dispatcher when a
  # workspace button is clicked.  Lua-configured Hyprland rejects that syntax.
  waybarLuaWorkspaces = pkgs.waybar.overrideAttrs (oldAttrs: {
    patches =
      (oldAttrs.patches or [])
      ++ [
        (pkgs.writeText "waybar-hyprland-lua-workspace-click.patch" ''
          diff --git a/src/modules/hyprland/workspace.cpp b/src/modules/hyprland/workspace.cpp
          --- a/src/modules/hyprland/workspace.cpp
          +++ b/src/modules/hyprland/workspace.cpp
          @@ -73,9 +73,12 @@ bool Workspace::handleClicked(GdkEventButton* bt) const {
                 if (id() > 0) {  // normal
                   if (m_workspaceManager.moveToMonitor()) {
          -          m_ipc.getSocket1Reply("dispatch focusworkspaceoncurrentmonitor " + std::to_string(id()));
          +          m_ipc.getSocket1Reply(
          +              "/dispatch hl.dsp.focus({ workspace = \"" + std::to_string(id()) +
          +              "\", on_current_monitor = true })");
                   } else {
          -          m_ipc.getSocket1Reply("dispatch workspace " + std::to_string(id()));
          +          m_ipc.getSocket1Reply("/dispatch hl.dsp.focus({ workspace = \"" +
          +                                std::to_string(id()) + "\" })");
                   }
                 } else if (!isSpecial()) {  // named (this includes persistent)
                   if (m_workspaceManager.moveToMonitor()) {
        '')
      ];
  });
in {
  # Enable Hyprland
  programs.hyprland.enable = true;
  # swaylock - commented for hyprlock migration
  #security.pam.services.swaylock = {};
  # hyprlock
  security.pam.services.hyprlock = {};
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";
  # Thunar
  programs.thunar.enable = true;
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images

  programs.thunar.plugins = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];

  environment.systemPackages = with pkgs; [
    firefox
    alacritty
    waybarLuaWorkspaces
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
    # cider # apple music client
    zoom-us
    marktext
    obsidian
    nomachine-client
    imagemagick
    pro-office-calculator
    # sddm deps
    qt5.qtgraphicaleffects
    qt5.qtquickcontrols2
    # todoist
    todoist-electron
  ];
}
