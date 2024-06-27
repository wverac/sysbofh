{...}: {
  # XDG MIME Default Apps
  # xdg-settings get default-web-browser
  # xdg-settings set default-web-browser google-chrome.desktop
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "text/html" = "google-chrome.desktop";
    "x-scheme-handler/http" = "google-chrome.desktop";
    "x-scheme-handler/https" = "google-chrome.desktop";
    "x-scheme-handler/about" = "google-chrome.desktop";
    "x-scheme-handler/unknown" = "google-chrome.desktop";
    "x-scheme-handler/tg" = "org.telegram.desktop.desktop";
    "x-scheme-handler/chrome" = "google-chrome.desktop";
    "application/x-extension-htm" = "google-chrome.desktop";
    "application/x-extension-html" = "google-chrome.desktop";
    "application/x-extension-shtml" = "google-chrome.desktop";
    "application/xhtml+xml" = "google-chrome.desktop";
    "application/x-extension-xhtml" = "google-chrome.desktop";
    "application/x-extension-xht" = "google-chrome.desktop";
    "application/pdf" = "org.pwmt.zathura-pdf-mupdf.desktop";
    "text/css" = "code.desktop";
    "application/x-shellscript" = "code.desktop";
    "text/markdown" = "code.desktop";
    "text/plain" = "code.desktop";
    "image/png" = "feh.desktop";
  };
}
