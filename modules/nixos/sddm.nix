{pkgs, ...}: {
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    theme = "where_is_my_sddm_theme";
    extraPackages = with pkgs; [
      kdePackages.qt5compat
    ];
  };

  environment.systemPackages = with pkgs; [
    where-is-my-sddm-theme
  ];
}
