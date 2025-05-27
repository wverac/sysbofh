{...}: {
  programs.ghostty = {
    enable = true;
    enableBashIntegration = true;
    themes = {
      catppuccin-mocha = {
        background = "1e1e2e";
        cursor-color = "f5e0dc";
        foreground = "cdd6f4";
        palette = [
          "0=#45475a"
          "1=#f38ba8"
          "2=#a6e3a1"
          "3=#f9e2af"
          "4=#89b4fa"
          "5=#f5c2e7"
          "6=#94e2d5"
          "7=#bac2de"
          "8=#585b70"
          "9=#f38ba8"
          "10=#a6e3a1"
          "11=#f9e2af"
          "12=#89b4fa"
          "13=#f5c2e7"
          "14=#94e2d5"
          "15=#a6adc8"
        ];
        selection-background = "353749";
        selection-foreground = "cdd6f4";
      };
    };
    settings = {
      term = "xterm-256color";
      keybind = [
        "ctrl+alt+s=toggle_tab_overview"
      ];
      theme = "catppuccin-mocha";
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;
      font-synthetic-style = "no-bold";
      cursor-style = "block";
      cursor-style-blink = true;
      mouse-hide-while-typing = true;
      background-opacity = 0.9;
      window-save-state = "always";
      window-padding-balance = true;
      window-padding-x = 5;
      window-padding-y = 2;
      maximize = true;
      working-directory = "home";
      window-inherit-working-directory = false;
      gtk-tabs-location = "hidden";
      app-notifications = "no-clipboard-copy";
    };
  };
}
