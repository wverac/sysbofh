# Overlay to add prefix indicator icon to onedark-theme for nixlab
final: prev: {
  tmuxPlugins =
    prev.tmuxPlugins
    // {
      onedark-theme = prev.tmuxPlugins.onedark-theme.overrideAttrs (oldAttrs: {
        postInstall =
          (oldAttrs.postInstall or "")
          + ''
            # Patch status-left: 󰙨 icon normally, 󰠠 when prefix is pressed
            substituteInPlace $out/share/tmux-plugins/onedark-theme/tmux-onedark-theme.tmux \
              --replace-fail '#S #{prefix_highlight}' '#{?client_prefix,󰠠 ,󰙨 }#S '
          '';
      });
    };
}
