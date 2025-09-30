{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      better-mouse-mode
      yank
      # nord # Default theme for nix extra systems
      gruvbox # Default theme for nix module
    ];
    extraConfig = ''
      unbind C-b
      set-option -g prefix C-q
      bind-key C-a send-prefix
      set -g history-limit 90000
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      set -g base-index 1
      setw -g pane-base-index 1

      # Mouse and clipboard configuration
      set-option -g mouse on
      set-option -s set-clipboard on

      # Cross-platform terminal overrides
      set -ga terminal-overrides ',xterm*:XT:Ms=\E]52;%p1%s;%p2%s\007'
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[2 q'
      # macOS specific overrides for iTerm2 and Terminal.app
      set -ga terminal-overrides ',*256col*:Tc'
      set -ga terminal-overrides ',alacritty:RGB'

      # Scroll optimizations for touchpad
      set -g @scroll-speed-num-lines 5
      set -g @scroll-down-exit-copy-mode off
      set -g @scroll-without-changing-pane on
      set -g @emulate-scroll-for-no-mouse-alternate-buffer on
      set -g @scroll-in-moused-over-pane on

      # Performance settings (prevents prompt issues)
      set -sg escape-time 10
      set -g focus-events on
      set -g repeat-time 300

      # Vi-mode for better selection
      setw -g mode-keys vi
      set -g @yank_selection_mouse 'clipboard'

      # Smooth scroll in copy-mode
      bind-key -T copy-mode-vi WheelUpPane send-keys -N3 -X scroll-up
      bind-key -T copy-mode-vi WheelDownPane send-keys -N3 -X scroll-down
      bind-key -T copy-mode WheelUpPane send-keys -N3 -X scroll-up
      bind-key -T copy-mode WheelDownPane send-keys -N3 -X scroll-down

      # Fine touchpad scroll with shift
      bind-key -T copy-mode-vi S-WheelUpPane send-keys -X scroll-up
      bind-key -T copy-mode-vi S-WheelDownPane send-keys -X scroll-down

      # Enhanced copy mode bindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      # Cross-platform clipboard copy (auto-detects pbcopy/xclip/wl-copy)
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection
      bind-key -T copy-mode-vi DoubleClick1Pane send-keys -X select-word
      bind-key -T copy-mode-vi TripleClick1Pane send-keys -X select-line

      # Terminal settings - optimized for cross-platform
      set -g default-terminal "tmux-256color"
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
    '';
  };
}
