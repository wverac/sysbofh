# Power management and USB4 for the N1X platform.
{pkgs, ...}: let
  # Let the platform pick the CPU operating point.
  cppcAutonomous = pkgs.writeShellScript "n1x-cppc-autonomous" ''
    for p in /sys/devices/system/cpu/cpufreq/policy*; do
      [ -w "$p/auto_select" ] || continue
      echo 0 > "$p/auto_select"
      read -r max < "$p/cpuinfo_max_freq" && echo "$max" > "$p/scaling_max_freq"
      read -r min < "$p/cpuinfo_min_freq" && echo "$min" > "$p/scaling_min_freq"
      echo 1 > "$p/auto_select"
    done
  '';

  # Battery charge limit, percent.
  chargeLimit = 80;
  setChargeLimit = pkgs.writeShellScript "n1x-charge-limit" ''
    for b in /sys/class/power_supply/BAT*; do
      [ -w "$b/charge_control_end_threshold" ] || continue
      echo ${toString chargeLimit} > "$b/charge_control_end_threshold"
    done
  '';
in {
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="module", KERNEL=="cppc_cpufreq", RUN+="${cppcAutonomous}"
    ACTION=="online", SUBSYSTEM=="cpu", TEST=="cpufreq/auto_select", ATTR{cpufreq/auto_select}="0", ATTR{cpufreq/scaling_max_freq}="$attr{cpufreq/cpuinfo_max_freq}", ATTR{cpufreq/scaling_min_freq}="$attr{cpufreq/cpuinfo_min_freq}", ATTR{cpufreq/auto_select}="1"
    ACTION=="bind", SUBSYSTEM=="platform", DRIVER=="asus-nb-wmi", RUN+="${setChargeLimit}"
  '';

  # Reserve PCI resources for USB4 docks.
  boot.kernelParams = ["pci=hpbussize=0x80,hpmmiosize=32M,hpmmioprefsize=32G"];
}
