# sops-nix still builds sops-install-secrets with buildGo125Module, which
# nixpkgs removed when Go 1.25 reached end of life. The module resolves
# sops.package against this flake's nixpkgs, so every evaluation fails until
# upstream moves to a current builder. Alias it back; drop this overlay once
# Mic92/sops-nix updates. See pkgs/sops-install-secrets/default.nix upstream.
final: prev: {
  buildGo125Module = prev.buildGoModule;
}
