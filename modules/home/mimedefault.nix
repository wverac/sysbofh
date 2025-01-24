{...}: {
  # XDG MIME Default Apps
  # xdg-settings get default-web-browser
  # xdg-settings set default-web-browser brave.desktop
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = "brave.desktop";
    "x-scheme-handler/http" = "brave.desktop";
    "x-scheme-handler/https" = "brave.desktop";
    "x-scheme-handler/about" = "brave.desktop";
    "x-scheme-handler/unknown" = "brave.desktop";
    "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
    "x-scheme-handler/chrome" = "google-chrome.desktop";
    "application/x-extension-htm" = "brave.desktop";
    "application/x-extension-html" = "brave.desktop";
    "application/x-extension-shtml" = "brave.desktop";
    "application/xhtml+xml" = "brave.desktop";
    "application/x-extension-xhtml" = "brave.desktop";
    "application/x-extension-xht" = "brave.desktop";
    "application/pdf" = "org.gnome.Evince.desktop";
    "text/css" = "code.desktop";
    "application/x-shellscript" = "code.desktop";
    "text/markdown" = "code.desktop";
    "text/plain" = "code.desktop";
    "image/png" = "org.gnome.eog.desktop";
    "image/jpeg" = "org.gnome.eog.desktop";
  };
}
