{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.nord;
      }
      tmuxPlugins.nord
    ];
    extraConfig = ''
      # remap prefix from 'C-b' to 'C-q'
      unbind C-b
      set-option -g prefix C-q
      bind-key C-a send-prefix
      set -g history-limit 90000
      # Set bind key to reload configuration file
      bind r source-file ~/.tmux.conf \; display "Reloaded!"
      #Activity Monitoring
      #setw -g monitor-activity on
      #set -g visual-activity on
      # Split panes with | and -
      #unbind '"'
      #unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      # Start windows and panes at 1, not 0
      set -g base-index 1
      setw -g pane-base-index 1
      # https://www.rockyourcode.com/copy-and-paste-in-tmux/
      # requires: xclip
      # NOTE: Avoid insert mode with select in nvim
      ## Use vim keybindings in copy mode
      ##set-option -g mouse on
      setw -g mouse on
      bind -n MouseDrag1Pane if-shell -F "#{pane_in_mode}" "send-keys -X begin-selection" "send-keys -M"
      setw -g mode-keys vi
      set-option -s set-clipboard off
      bind P paste-buffer
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X rectangle-toggle
      unbind -T copy-mode-vi Enter
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
      bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
    '';
  };
}
