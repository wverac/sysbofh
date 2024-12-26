{...}: {
  services.logind = {
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
    # NOTE: ignore lidSwitch, testing docking station
    # lidSwitch = "suspend-then-hibernate";
    # lidSwitchExternalPower = "suspend";
    # lidSwitchDocked = "suspend-then-hibernate";
    lidSwitch = "ignore";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
    extraConfig = ''
    '';
  };
}
