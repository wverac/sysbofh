{pkgs, ...}: {
  # Fonts
  fonts.packages = with pkgs; [
    font-awesome
    powerline-fonts
    powerline-symbols
    jetbrains-mono
    nerd-font-patcher
    (nerd-fonts.jetbrains-mono)
  ];
}
