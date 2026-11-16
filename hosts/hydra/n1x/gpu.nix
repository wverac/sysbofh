# NVIDIA GPU of the N1X SoC, see ./SOURCES.md.
{
  config,
  lib,
  ...
}: let
  patchDir = ./nvidia-patches;
  patchNames =
    lib.filter (n: lib.hasSuffix ".patch" n)
    (lib.attrNames (builtins.readDir patchDir));
in {
  hardware.graphics.enable = true;

  # Load the NVIDIA driver.
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
    nvidiaSettings = false;
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "615.78.08";
      sha256_64bit = "sha256-Pj9t3cLudnoIGFMAr3vjyyhuznZpjS3eNSRZl4LQf/4=";
      sha256_aarch64 = "sha256-UHYBE1AYHoGgMfD9AS/jX+S+N8eCDWUft6qolK9Eejc=";
      openSha256 = "sha256-HBINiOjL0ZJLIAJeNIBYHBnwgUXtNwPPtnFpAI1YwF4=";
      settingsSha256 = "sha256-inDRpG02sdDgHmlqgu/DsgK8OFdOt1fZIYyXdhlGC/c=";
      persistencedSha256 = "sha256-RzeR6Ldct6MUxjnXRyThdh5Y3jjMehTVg85MtwuWNX4=";
      # One store path per patch.
      patchesOpen = map (n:
        builtins.path {
          path = patchDir + "/${n}";
          name = n;
        })
      patchNames;
    };
  };
}
