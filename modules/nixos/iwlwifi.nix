{...}: {
  # My homelab wifi card: Intel Corporation Wi-Fi 6 AX101NGW
  # Append Kernel modules
  boot.kernelModules = [
    "brcmfmac"
    "brcmutil"
    "iwlmvm"
    "iwlwifi"
    "mmc_core"
    "mt76_usb"
    "mt76"
    "mt76x0_common"
    "mt76x02_lib"
    "mt76x02_usb"
    "mt76x0u"
    "r8188eu"
    "rtl_usb"
    "rtl8192c_common"
    "rtl8192cu"
    "rtlwifi"
  ];
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;
}
