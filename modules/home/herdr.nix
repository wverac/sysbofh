{pkgs, ...}: let
  # herdr has no confirmation for close_pane, only for workspaces (confirm_close).
  # prefix+x opens this in a popup and closes the pane only on "y".
  confirmClosePane = pkgs.writeShellScript "herdr-confirm-close-pane" ''
    pane="''${HERDR_ACTIVE_PANE_ID:-}"
    [ -n "$pane" ] || { echo "✘ no active pane id"; sleep 2; exit 1; }
    printf 'Close pane %s? [y/N] ' "$pane"
    read -r -n1 answer
    [ "$answer" = y ] || [ "$answer" = Y ] && herdr pane close "$pane"
  '';
in {
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
        resize_pane_left = "prefix+shift+left";
        resize_pane_down = "prefix+shift+down";
        resize_pane_up = "prefix+shift+up";
        resize_pane_right = "prefix+shift+right";
        # Unbind the default immediate close, the popup below takes prefix+x.
        close_pane = "";
        command = [
          {
            key = "prefix+x";
            type = "popup";
            command = "${confirmClosePane}";
            width = 40;
            height = 5;
          }
        ];
      };
    };
  };
}
