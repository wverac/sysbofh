{pkgs, ...}: {
  # Enable SDDM custom theme
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.theme = "${(pkgs.fetchFromGitHub {
    owner = "wverac";
    repo = "bofh-theme-sddm";
    rev = "317fdb36788e98b616ea4c15fabad20471bf6ba4";
    sha256 = "sha256-N6bxzoEgpJgY335Gagkh1viNe+gXJzznaJPfDLuAtX0=";
  })}";
}
