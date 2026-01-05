# Package modifications/fixes overlay
# See: https://github.com/NixOS/nixpkgs/issues/476278
final: prev: {
  # Hydra build fails due to GCC 15 / libpqxx issue - skip tests temporarily
  hydra = prev.hydra.overrideAttrs (_: {
    doCheck = false;
    doInstallCheck = false;
  });
}
