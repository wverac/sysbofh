# Pin NoMachine to the current upstream tarball while nixpkgs catches up.
final: prev: {
  nomachine-client = prev.nomachine-client.overrideAttrs (_old: {
    version = "9.8.2";
    src = prev.fetchurl {
      url = "https://download.nomachine.com/download/9.8/Linux/nomachine_9.8.2_1_x86_64.tar.gz";
      hash = "sha256-bpXYeErjx4+soxsSI6EMO0lfFUEJAc5YT3ZIfkTdRBo=";
    };
  });
}
