{...}: {
  services.logind = {
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
    lidSwitch = "suspend-then-hibernate";
    lidSwitchExternalPower = "suspend";
    lidSwitchDocked = "suspend-then-hibernate";
    extraConfig = ''
    '';
  };
}
