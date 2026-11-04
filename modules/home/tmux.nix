{
  pkgs,
  lib,
  hostname ? "unknown",
  ...
}: let
  # Theme configuration per hostname
  themeConfig = {
    sysbofh = {
      plugin = pkgs.tmuxPlugins.tokyo-night-tmux;
      extraConfig = ''
        set -g @tokyo-night-tmux_theme 'storm'
        set -g @tokyo-night-tmux_window_id_style 'hsquare'
        set -g @tokyo-night-tmux_pane_id_style 'hsquare'
        set -g @tokyo-night-tmux_zoom_id_style 'dsquare'
        set -g @tokyo-night-tmux_show_netspeed '0'
        set -g @tokyo-night-tmux_show_wbg '1'
        # Plugin 1.8.1 reads these but never assigns a default, so the widgets
        # print "invalid option" instead of rendering unless they are declared.
        set -g @tokyo-night-tmux_transparent '0'
        set -g @tokyo-night-tmux_show_git '1'
      '';
    };
    nixlab = {
      plugin = pkgs.tmuxPlugins.onedark-theme;
      extraConfig = ''
        set -g @onedark_time_format '%I:%M %p'
        set -g @onedark_date_format '%D'
      '';
    };
  };

  # Fallback to gruvbox if hostname not found
  selectedTheme = themeConfig.${hostname} or themeConfig.sysbofh;
  githubStatusScript = pkgs.writeShellScript "tmux-github-status" ''
    export PATH=${lib.makeBinPath [
      pkgs.bash
      pkgs.bc
      pkgs.coreutils
      pkgs.gh
      pkgs.git
      pkgs.gawk
      pkgs.gnugrep
      pkgs.gnused
      pkgs.jq
      pkgs.tmux
    ]}
    exec ${pkgs.coreutils}/bin/timeout 15s \
      ${pkgs.tmuxPlugins.tokyo-night-tmux}/share/tmux-plugins/tokyo-night-tmux/src/wb-git-status.sh "$@"
  '';
  githubStatus =
    lib.optionalString (hostname == "sysbofh")
    "#(${githubStatusScript} #{pane_current_path})";

  # The theme builds status-right itself and embeds a bare call to its own git
  # widget. Swap that call for the wrapped script, which pins PATH and adds a
  # timeout so a hung gh cannot freeze the status bar.
  gitWidgetSwap = pkgs.writeShellScript "tmux-git-widget-swap" ''
    current=$(${pkgs.tmux}/bin/tmux show-options -gv status-right)
    patched=$(printf '%s' "$current" \
      | ${pkgs.gnused}/bin/sed 's|#([^)]*wb-git-status\.sh[^)]*)|${githubStatus}|')
    ${pkgs.tmux}/bin/tmux set -g status-right "$patched"
  '';
  gitWidgetSwapCall =
    lib.optionalString (hostname == "sysbofh")
    "run-shell ${gitWidgetSwap}";
in {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      resurrect
      {
        plugin = selectedTheme.plugin;
        extraConfig = selectedTheme.extraConfig;
      }
    ];
    extraConfig = ''
      # Prefix key configuration
      unbind C-b
      set-option -g prefix C-q
      bind-key C-a send-prefix

      # History and reload
      set -g history-limit 90000
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      # Window splitting
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # Base index
      set -g base-index 1
      setw -g pane-base-index 1
      set -g renumber-windows on

      # Mouse configuration
      set-option -g mouse on
      set-option -s set-clipboard on

      # Terminal overrides for OSC 52 clipboard
      set -ga terminal-overrides ',xterm*:XT:Ms=\E]52;%p1%s;%p2%s\007'
      # Cursor shape: Ss = set cursor style, Se = reset to blinking block
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[1 q'

      # Performance settings (balanced for responsive copy-mode exit)
      set -sg escape-time 50
      set -g focus-events off
      set -g repeat-time 200

      # The theme builds the whole status bar, window list included, and its
      # own status-left already carries the Nix icon next to the session name.
      # Only the refresh interval is forced here, to keep the gh calls of the
      # git widget infrequent. Both lines run after the theme, so they win.
      set -g status-interval 30
      ${gitWidgetSwapCall}

      # Vi-mode for selection
      setw -g mode-keys vi
      set -g @yank_selection_mouse 'clipboard'

      # Scroll wheel enters copy-mode when not already in it
      bind-key -T root WheelUpPane if-shell -F "#{||:#{pane_in_mode},#{mouse_any_flag}}" { send-keys -M } { copy-mode -e }
      bind-key -T root WheelDownPane send-keys -M

      # Smooth scroll in copy-mode (3 lines up, single down for auto-exit)
      bind-key -T copy-mode-vi WheelUpPane send-keys -N3 -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -X scroll-down
      bind-key -T copy-mode WheelUpPane send-keys -N3 -X scroll-up
      bind-key -T copy-mode WheelDownPane send-keys -X scroll-down

      # Fine touchpad scroll with shift
      bind-key -T copy-mode-vi S-WheelUpPane send-keys -X scroll-up
      bind-key -T copy-mode-vi S-WheelDownPane send-keys -X scroll-down

      # Copy mode vi bindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

      # Exit copy-mode bindings
      bind-key -T copy-mode-vi Escape send-keys -X cancel
      bind-key -T copy-mode-vi q send-keys -X cancel
      bind-key -T copy-mode Escape send-keys -X cancel
      bind-key -T copy-mode q send-keys -X cancel

      # Unbind MouseDown1Pane to prevent accidental copy-mode cancel
      unbind-key -T copy-mode-vi MouseDown1Pane
      unbind-key -T copy-mode MouseDown1Pane

      # Mouse drag copies and exits copy-mode immediately
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection-and-cancel
      bind-key -T copy-mode MouseDragEnd1Pane send-keys -X copy-selection-and-cancel

      # Double/triple click selection
      bind-key -T copy-mode-vi DoubleClick1Pane send-keys -X select-word
      bind-key -T copy-mode-vi TripleClick1Pane send-keys -X select-line

      # Terminal type
      set -g default-terminal "tmux-256color"
    '';
  };
}
