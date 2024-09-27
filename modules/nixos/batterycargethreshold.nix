{...}: {
  # The TLP power management  it is not compatible with system76
  # https://support.system76.com/articles/battery/

  systemd.services.setChargeThreshold = {
    description = "Set Battery Charge Control Threshold";
    wantedBy = ["multi-user.target"];
    after = ["multi-user.target"];
    startLimitBurst = 0;
    script = ''
      echo 40 > /sys/class/power_supply/BAT0/charge_control_start_threshold
      echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold
    '';
    serviceConfig = {
      Type = "oneshot";
      Restart = "on-failure";
    };
  };
}
