{pkgs, ...}: {
  programs.herdr = {
    enable = true;
    package = pkgs.herdr;
    mutableSettings = true;

    settings = {
      onboarding = false;

      theme = {
        name = "kanagawa";
        auto_switch = false;
      };

      keys = {
        prefix = "ctrl+q";
        split_horizontal = "prefix+minus";
        split_vertical = "prefix+|";
      };
    };
  };
}
