{...}: {
  # Optimizations for large Nix builds

  # Build on tmpfs — keeps compilation I/O in RAM instead of hitting disk.
  # 75% of 38GB RAM = ~28GB, more than enough for kernel builds.
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "75%";

  # Compressed in-memory swap as a safety net. Without swap, the OOM killer
  # will start terminating build processes when RAM fills up.
  zramSwap = {
    enable = true;
    memoryPercent = 25;
  };

  # Increase download buffer to avoid stalls when fetching large derivations.
  nix.settings.download-buffer-size = 268435456; # 256 MiB
}
