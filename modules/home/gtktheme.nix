{pkgs, ...}: {
  # GTK Theme
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    # x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 16;
  };

  gtk = {
    enable = true;

    # GTK 3
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3";
    };

    # GTK 2
    gtk2.theme = {
      package = pkgs.gnome-themes-extra;
      name = "Adwaita";
    };

    # GTK 4/libadwaita
    gtk4.theme = null;

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };

    font = {
      name = "Sans";
      size = 11;
    };
  };
}
