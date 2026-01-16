{
  pkgs,
  lib,
  ...
}: {
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    TERM = "xterm-256color";
  };

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      {
        plugin = gruvbox;
        extraConfig = ''
          set -g @tmux-gruvbox 'dark'
        '';
      }
    ];
    extraConfig = ''
      # Prefix key configuration
      unbind C-b
      set-option -g prefix C-q
      bind-key C-a send-prefix

      # Status-left: Apple icon (󰀵) +  normally, 󰠠 when prefix is pressed (matches overlay behavior for NixOS)
      # #S = session name
      set -g status-left '#{?client_prefix, 󰠠 , 󰀵 }#S '

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
      set -g allow-passthrough on

      # Terminal overrides for OSC 52 clipboard
      set -ga terminal-overrides ',xterm*:XT:Ms=\E]52;%p1%s;%p2%s\007'
      # Cursor shape: Ss = set cursor style, Se = reset to blinking block
      set -ga terminal-overrides ',*:Ss=\E[%p1%d q:Se=\E[1 q'
      # macOS true color support
      set -ga terminal-overrides ",xterm-256color:Tc"
      set -sa terminal-overrides ',*:RGB'

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

      # Copy mode vi bindings (using pbcopy for macOS)
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'

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

      # Ensure proper locale inside tmux (macOS-specific)
      set-environment -g LANG en_US.UTF-8
      set-environment -g LC_ALL en_US.UTF-8
      set-environment -g LC_CTYPE en_US.UTF-8
    '';
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cat = "bat --paging=never";
      lcat = "bat --style=plain --paging=never";
      ls = lib.mkForce "lsd";
      ll = lib.mkForce "lsd -latrh";
      vim = lib.mkForce "nvim";
    };
    initExtra = ''
      # Force UTF-8 encoding for macOS
      export LANG="en_US.UTF-8"
      export LC_ALL="en_US.UTF-8"
      export LC_CTYPE="en_US.UTF-8"
      export TERM="xterm-256color"

      # Add ~/.local/bin to PATH on Darwin
      export PATH="$HOME/.local/bin:$PATH"
    '';
    profileExtra = ''
      # Ensure locale is set early in profile
      export LANG="en_US.UTF-8"
      export LC_ALL="en_US.UTF-8"
      export LC_CTYPE="en_US.UTF-8"
    '';
  };

  home.file.".inputrc".text = ''
    set input-meta on
    set output-meta on
    set convert-meta off
  '';
}
