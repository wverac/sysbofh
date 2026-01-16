# Overlay to add Gruvbox Dark theme and fixed-width netspeed to tokyo-night-tmux plugin
final: prev: {
  tmuxPlugins =
    prev.tmuxPlugins
    // {
      tokyo-night-tmux = prev.tmuxPlugins.tokyo-night-tmux.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            # Patch themes.sh to add gruvbox theme
            substituteInPlace $out/share/tmux-plugins/tokyo-night-tmux/src/themes.sh \
              --replace-fail '"storm")' '"gruvbox")
              declare -A THEME=(
                ["background"]="#282828"
                ["foreground"]="#ebdbb2"
                ["black"]="#3c3836"
                ["blue"]="#83a598"
                ["cyan"]="#8ec07c"
                ["green"]="#b8bb26"
                ["magenta"]="#d3869b"
                ["red"]="#fb4934"
                ["white"]="#ebdbb2"
                ["yellow"]="#fabd2f"

                ["bblack"]="#504945"
                ["bblue"]="#458588"
                ["bcyan"]="#689d6a"
                ["bgreen"]="#98971a"
                ["bmagenta"]="#b16286"
                ["bred"]="#cc241d"
                ["bwhite"]="#a89984"
                ["byellow"]="#d79921"
              )
              ;;

            "storm")'

            # Patch lib/netspeed.sh to use fixed-width output (prevents bar jumping)
            substituteInPlace $out/share/tmux-plugins/tokyo-night-tmux/lib/netspeed.sh \
              --replace-fail 'echo "$(bc -l <<<"scale=1; $bytes / 1024 / $secs")KB/s"' \
                             'printf "%5.1fK\n" "$(bc -l <<<"scale=1; $bytes / 1024 / $secs")"' \
              --replace-fail 'echo "$(bc -l <<<"scale=1; $bytes / 1048576 / $secs")MB/s"' \
                             'printf "%5.1fM\n" "$(bc -l <<<"scale=1; $bytes / 1048576 / $secs")"'

            # Patch status-left to add NixOS icon (󱄅) before session name
            substituteInPlace $out/share/tmux-plugins/tokyo-night-tmux/tokyo-night.tmux \
              --replace-fail '#[bold,nodim]#S' '#[bold,nodim]󱄅 #S'
          '';
      });
    };
}
