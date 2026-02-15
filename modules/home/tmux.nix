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
        set -g @tokyo-night-tmux_theme 'gruvbox'
        set -g @tokyo-night-tmux_window_id_style 'hsquare'
        set -g @tokyo-night-tmux_pane_id_style 'hsquare'
        set -g @tokyo-night-tmux_zoom_id_style 'dsquare'
        set -g @tokyo-night-tmux_show_netspeed '1'
        set -g @tokyo-night-tmux_show_wbg '1'
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
in {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
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
