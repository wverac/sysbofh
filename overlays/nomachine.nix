# Pin NoMachine to the current upstream tarball while nixpkgs catches up.
final: prev: {
  nomachine-client = prev.nomachine-client.overrideAttrs (_old: {
    version = "9.5.7";
    src = prev.fetchurl {
      url = "https://download.nomachine.com/download/9.5/Linux/nomachine_9.5.7_2_x86_64.tar.gz";
      hash = "sha256-8f4ZL3Ko5VunojXLvTS9P3oB+ZVCSYIA0GIjM8VpUO4=";
    };
  });
}
