{pkgs, ...}: {
  programs.bash.blesh.enable = true;
  environment.etc."bashrc".text = ''
     if [[ -s "${pkgs.blesh}/share/blesh/ble.sh" ]]; then
       source "${pkgs.blesh}/share/blesh/ble.sh"
     fi
  '';
}
