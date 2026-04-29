# Pin NoMachine to the current upstream tarball while nixpkgs catches up.
final: prev: {
  nomachine-client = prev.nomachine-client.overrideAttrs (_old: {
    version = "9.4.14";
    src = prev.fetchurl {
      url = "https://download.nomachine.com/download/9.4/Linux/nomachine_9.4.14_1_x86_64.tar.gz";
      hash = "sha256-tLL8l/UgTiVzGs+mwJeRUlVA8lH72JVogBOEpaSr2AY=";
    };
  });
}
