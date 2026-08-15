{...}: {
  services.logind = {
    settings = {
      Login = {
        HandlePowerKey = "lock";
        HandlePowerKeyLongPress = "poweroff";

        # suspend-then-hibernate is unsupported (zram only, no resume device);
        # logind's fallback queues duplicate suspends that re-fire on lid open
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "lock";
        HandleLidSwitchDocked = "lock";
        InhibitDelayMaxSec = "15s";
      };
    };
  };
}
