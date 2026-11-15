# Kernel for the NVIDIA N1X platform, see ./SOURCES.md.
{
  lib,
  pkgs,
  ...
}: let
  patchDir = ./patches;
  patchNames =
    lib.filter (n: lib.hasSuffix ".patch" n)
    (lib.attrNames (builtins.readDir patchDir));

  kernel = pkgs.linux_7_3.override {
    argsOverride = rec {
      version = "7.3";
      modDirVersion = "7.3.0";
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v7.x/linux-${version}.tar.xz";
        sha256 = "0ls902gz6h1ydcnwx2zzdcglg52f14hmaxk2ncg341hfy4j3qdl7";
      };
    };
  };
in {
  boot.kernelPackages = pkgs.linuxPackagesFor kernel;

  # Keyboard and touchpad drivers in the initrd.
  boot.initrd.kernelModules = ["i2c_hid_acpi" "hid_asus" "hid_multitouch"];

  # Applied in name order.
  boot.kernelPatches =
    map (n: {
      name = lib.removeSuffix ".patch" n;
      # One store path per patch.
      patch = builtins.path {
        path = patchDir + "/${n}";
        name = n;
      };
    })
    patchNames
    ++ [
      {
        name = "n1x-platform-config";
        patch = null;
        structuredExtraConfig = with lib.kernel; {
          # SoC I/O
          PINCTRL_MT8901 = yes;
          MTK_POWER_WRAP = yes;
          MTK_SSPM_CI = yes;
          USB_XHCI_MTK_V2 = module;
          # Embedded controller
          ARM_FFA_TRANSPORT = lib.mkForce yes;
          ACPI_FFH = yes;
          ACPI_EC = option yes;
          NVIDIA_FFA_EC = yes;
          # USB4 and Thunderbolt
          USB4_PLATFORM_NHI = module;
          # Audio
          SOUNDWIRE_MTK = module;
          SOUNDWIRE_MTK_MT8901_CLK = yes;
          SND_SOC_MT8901 = module;
          SND_SOC_MT8901_LEGACY_SDW_MACH = module;
          SND_SOC_MTK_SDCA = module;
          SND_SOC_SOF_MT8901 = module;
        };
      }
    ];
}
