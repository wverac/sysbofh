# Pin NoMachine to the current upstream tarball while nixpkgs catches up.
final: prev: {
  nomachine-client = prev.nomachine-client.overrideAttrs (_old: {
    version = "10.0.60";
    src = prev.fetchurl {
      url = "https://download.nomachine.com/download/10.0/Linux/nomachine-personal-edition_10.0.60_1_x86_64.tar.gz";
      hash = "sha256-BSjWCmi/Wz//8yO4aj2KnpGeCkND2ASsE7nhW0pBAQI=";
    };
  });
}
