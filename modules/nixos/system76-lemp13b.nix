{pkgs, ...}: {
  # Hardware setup for System76 Lemur Pro 13 (lemp13-b)
  #
  # Note: system76-power logs "[ERROR] fan daemon: platform hwmon not found"
  # on every boot. This is expected — that code path is for Thelio desktops
  # only. Laptop fan control is handled entirely by the EC firmware.

  hardware.system76 = {
    # Enables: power-daemon, kernel-modules, firmware-daemon
    enableAll = true;
  };

  environment.systemPackages = with pkgs; [
    system76-keyboard-configurator
    system76-firmware
    system76-power
  ];

  # Silence-first thermal management. The EC firmware has a binary fan curve
  # that cannot be overridden (pwm1 is read-only, no pwm1_enable).
  # The EC triggers the fan based on package temps in the ~75-77C range.
  # The only control we have is limiting CPU power/frequency to keep temps
  # below that threshold.
  #
  # Tested values with typical workload (browser + terminal + editor):
  #   PL1=15W, 100% → fan always on (~80C package)
  #   PL1=10W, 35%  → fan intermittent (~77C package)
  #   PL1=8W,  30%  → fan mostly off (~70C ACPI, still ~80C package)
  #   PL1=5W,  20%  → fan off, but system too slow for normal use
  #   PL1=10W, 40%  → middle ground: usable performance, fan intermittent
  #
  # Trade-off: PL1=10W limits sustained power to ~67% of TDP.
  # Frequency caps at ~1.7GHz. Fan will run intermittently under load.
  #
  # DISABLED: fan noise vs. performance — noise wins!
  # These services capped CPU to 10W/40%/power which made the system nearly
  # unusable during heavy workloads (kernel builds, large rebuilds).
  # Keeping stock defaults: PL1=15W, max_perf_pct=100, EPP=balance_performance.

  # # Cap sustained power (PL1) to 10W and burst (PL2) to 15W.
  # # Stock values: PL1=15W, PL2=57W.
  # systemd.services.cpu-power-limits = {
  #   description = "Cap CPU power limits for silence-first thermal management";
  #   after = [ "sysinit.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.bash}/bin/bash -c '"
  #       + "echo 10000000 > /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw"
  #       + " && echo 15000000 > /sys/class/powercap/intel-rapl:0/constraint_1_power_limit_uw'";
  #   };
  # };

  # # Cap turbo to 40% of max (~1.7GHz). Base clock is 1.3GHz, max turbo 4.3GHz.
  # systemd.services.cpu-max-frequency = {
  #   description = "Limit CPU turbo frequency to reduce heat generation";
  #   after = [ "sysinit.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'echo 40 > /sys/devices/system/cpu/intel_pstate/max_perf_pct'";
  #   };
  # };

  # # Set EPP to "power" — most conservative energy preference.
  # systemd.services.cpu-energy-preference = {
  #   description = "Set CPU energy performance preference to power-saving";
  #   after = [ "sysinit.target" ];
  #   wantedBy = [ "multi-user.target" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     ExecStart = "${pkgs.bash}/bin/bash -c 'for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do echo power > \"$f\"; done'";
  #   };
  # };
}
