{pkgs, ...}: {
  programs.bat.enable = true;
  programs.lsd.enable = true;

  home.packages = with pkgs; [
    blesh
  ];

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cat = "bat --paging=never";
      ls = "lsd";
      ll = "lsd -latrh";
    };
    bashrcExtra = ''
      if [[ -s "${pkgs.blesh}/share/blesh/ble.sh" ]]; then
          source "${pkgs.blesh}/share/blesh/ble.sh"
      fi
    '';
  };
}
