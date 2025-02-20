{...}: {
  services.logind = {
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
    # NOTE: ignore lidSwitch, testing docking station
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    extraConfig = ''
    '';
  };
}
