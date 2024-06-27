{inputs, ...}: {
  # No pkgs yet
  # additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    hydra_unstable =
      (prev.hydra_unstable.overrideAttrs (old: {
        version = "2024-05-23";
        src = final.fetchFromGitHub {
          owner = "nixos";
          repo = "hydra";
          rev = "b3e0d9a8b78d55e5fea394839524f5a24d694230";
          hash = "sha256-WAJJ4UL3hsqsfZ05cHthjEwItnv7Xy84r2y6lzkBMh8=";
        };
        patches = [./hydra-restrict-eval.diff];
      }))
      .override {
        nix = final.nixVersions.nix_2_22;
      };
  };

  # When applied, the stable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.stable'
  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
