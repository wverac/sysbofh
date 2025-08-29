{...}: {
  services.logind = {
    settings = {
      Login = {
        HandlePowerKey = "suspend";
        HandlePowerKeyLongPress = "poweroff";

        # NOTE: ignore lidSwitch, testing docking station
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "ignore";
        HandleLidSwitchDocked = "ignore";
      };
    };
  };
}
