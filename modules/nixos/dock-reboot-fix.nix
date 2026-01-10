{lib, ...}: {
  # Fix for Dell WD22TB4 Thunderbolt dock reboot hang
  # Issue: r8152 USB ethernet driver fails to unbind properly during shutdown
  # Symptoms: System hangs after "Reached target System Reboot" with dock connected
  # Hardware: System76 Lemur Pro lemp13-b + Dell WD22TB4 Thunderbolt Dock

  boot.kernelParams = [
    # Use PCI reset method instead of ACPI (more reliable with Thunderbolt)
    "reboot=pci"
    # Disable USB autosuspend (prevents r8152 power management issues)
    "usbcore.autosuspend=-1"
  ];

  # r8152 driver options to improve stability
  boot.extraModprobeConfig = ''
    options r8152 napi_defer_hard_irqs=0
  '';

  # Reduce shutdown timeout (fail faster if hang occurs)
  systemd.settings.Manager.DefaultTimeoutStopSec = "30s";

  # Enable fwupd for dock firmware updates
  services.fwupd.enable = true;
}
