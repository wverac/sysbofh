{pkgs, ...}: {
  programs.herdr = {
    enable = true;
    package = pkgs.herdr;
    mutableSettings = true;

    settings = {
      onboarding = false;

      theme = {
        name = "kanagawa";
        auto_switch = false;
      };

      ui.toast.clipboard.position = "bottom-right";
      ui.tab_bar_right = [{type = "zoom";}];

      keys = {
        prefix = "ctrl+q";
        goto = ["prefix+a" "prefix+g"];
        switch_workspace = "prefix+shift+1..9";
        previous_workspace = "ctrl+alt+up";
        next_workspace = "ctrl+alt+down";
        split_horizontal = "prefix+minus";
        split_vertical = "prefix+|";
        focus_pane_left = ["prefix+left" "prefix+h"];
        focus_pane_down = ["prefix+down" "prefix+j"];
        focus_pane_up = ["prefix+up" "prefix+k"];
        focus_pane_right = ["prefix+right" "prefix+l"];
      };
    };
  };
}
