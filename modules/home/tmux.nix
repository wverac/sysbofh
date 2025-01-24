{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      #nord
      better-mouse-mode
      gruvbox
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
      set-option -g mouse on
      set -g allow-passthrough on
      set-option -s set-clipboard on
    '';
  };
}
