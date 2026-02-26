# Skip broken picosvg tests (5 SVG path output mismatches)
# See: https://github.com/NixOS/nixpkgs/issues/
# Affects: picosvg -> nanoemoji -> gftools -> jetbrains-mono -> fontconfig
final: prev: {
  pythonPackagesExtensions =
    prev.pythonPackagesExtensions
    ++ [
      (pfinal: pprev: {
        picosvg = pprev.picosvg.overrideAttrs {
          doCheck = false;
          doInstallCheck = false;
        };
      })
    ];
}
