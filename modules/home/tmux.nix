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
        set -g @tokyo-night-tmux_show_netspeed '0'
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

      # Stable status bar: keep the Gruvbox look without asynchronous plugin
      # widgets, which cause visible redraws when many windows are open.
      set -g status-interval 30
      set -g status-left "#[fg=#83a598,bg=#282828]#[fg=#282828,bg=#83a598,bold] #{?client_prefix,󰠠,󱄅} #S #[fg=#83a598,bg=#282828,nobold]"
      set -g status-right "${githubStatus}#[fg=#fabd2f,bg=#282828]#[fg=#282828,bg=#fabd2f,bold] 󰃭 %a %d %b  󰥔 %I:%M %p #[fg=#fabd2f,bg=#282828,nobold]"
      setw -g window-status-format "#[fg=#a89984,bg=#282828]   #I #W#{?window_zoomed_flag, 󰊓,} "
      setw -g window-status-current-format "#[fg=#b8bb26,bg=#282828]#[fg=#282828,bg=#b8bb26,bold]  #I #W#{?window_zoomed_flag, 󰊓,} #[fg=#b8bb26,bg=#282828,nobold]"
      set -g window-status-separator " "

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
