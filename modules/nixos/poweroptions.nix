{ ...}: {
  services.logind = {
    powerKey = "suspend";
    powerKeyLongPress = "poweroff";
    lidSwitch = "suspend";
    lidSwitchExternalPower = "ignore";
    extraConfig = ''
      "IdleAction=lock"
      "IdleActionSec=1m"
    '';
  };
}
