# Pin the opencode node_modules hash to the Linux value.
# nixpkgs c399e1b (2026-11-04) made this fixed-output hash platform conditional
# because "bun install" resolves different content on Linux and Darwin. The fix
# is only on master: nixos-unstable and nixpkgs-unstable still carry the single
# Darwin hash, so the derivation fails on this host with a hash mismatch.
# Linux only, do not wire this on minix. Drop it once the channel has c399e1b.
final: prev: {
  opencode = prev.opencode.overrideAttrs (old: {
    node_modules = old.node_modules.overrideAttrs (_: {
      outputHash = "sha256-prx9dX7kUvs/E3zopkaPk5LXh3xJAy5sZeum/W8L7cA=";
    });
  });
}
