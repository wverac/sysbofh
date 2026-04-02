# Fix marktext build: add missing node-gyp to nativeBuildInputs
# See: https://github.com/NixOS/nixpkgs/issues/
final: prev: {
  marktext = prev.marktext.overrideAttrs (old: {
    nativeBuildInputs =
      (old.nativeBuildInputs or [])
      ++ [
        final.node-gyp
      ];
  });
}
