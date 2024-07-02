{lib, ...}: {
  programs.bat.enable = true;
  programs.lsd.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      cat = "bat --paging=never";
      ls = "lsd";
      ll = "lsd -latrh";
    };
  };
}
