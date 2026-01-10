{pkgs, ...}: {
  # Fix for Dell WD22TB4 Thunderbolt dock reboot hang
  # Issue: r8152 USB ethernet driver fails to unbind properly during shutdown
  # Symptoms: System hangs after "Reached target System Reboot" with dock connected
  # Hardware: System76 Lemur Pro lemp13-b + Dell WD22TB4 Thunderbolt Dock

  boot.kernelParams = [
    # Use PCI reset method instead of ACPI (more reliable with Thunderbolt)
    "reboot=pci"
  ];

  # Reduce shutdown timeout (fail faster if hang occurs)
  systemd.settings.Manager.DefaultTimeoutStopSec = "30s";

  # Forcefully unbind r8152 USB devices and unload module before shutdown/reboot
  systemd.services.r8152-shutdown-fix = {
    description = "Unbind r8152 USB devices before shutdown to prevent hang";
    wantedBy = ["multi-user.target"];
    before = ["shutdown.target" "reboot.target" "halt.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.coreutils}/bin/true";
      ExecStop = pkgs.writeShellScript "r8152-unbind" ''
        # Unbind all r8152 USB devices
        if [ -d /sys/bus/usb/drivers/r8152 ]; then
          for dev in /sys/bus/usb/drivers/r8152/*/; do
            [ -d "$dev" ] || continue
            devname=$(${pkgs.coreutils}/bin/basename "$dev")
            case "$devname" in
              module|bind|unbind|uevent) continue ;;
            esac
            echo "$devname" > /sys/bus/usb/drivers/r8152/unbind 2>/dev/null || true
          done
        fi
        # Unload the module and dependencies
        ${pkgs.kmod}/bin/modprobe -r r8153_ecm 2>/dev/null || true
        ${pkgs.kmod}/bin/modprobe -r r8152 2>/dev/null || true
      '';
    };
  };

  # Enable fwupd for dock firmware updates
  services.fwupd.enable = true;
}
