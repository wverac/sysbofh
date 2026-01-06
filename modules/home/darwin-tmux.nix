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
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      gruvbox
    ];
    extraConfig = ''
      # Existing configuration
      unbind C-b
      set-option -g prefix C-q
      bind-key C-a send-prefix
      set -g history-limit 90000
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      set -g base-index 1
      setw -g pane-base-index 1
      set-option -g mouse on
      set -g allow-passthrough on
      set-option -s set-clipboard on
      set -g @scroll-speed-num-lines 5

      # macOS-specific terminal and encoding fixes
      set-option -g default-terminal "screen-256color"
      set-option -ga terminal-overrides ",xterm-256color:Tc"
      set-option -sa terminal-overrides ',*:RGB'

      # Fix character encoding issues
      set-option -g assume-paste-time 1
      set-option -g escape-time 10

      # Ensure proper locale inside tmux
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
