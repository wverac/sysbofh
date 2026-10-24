# Pin NoMachine to the current upstream tarball while nixpkgs catches up.
final: prev: {
  nomachine-client = prev.nomachine-client.overrideAttrs (_old: {
    version = "10.2.3";
    src = prev.fetchurl {
      url = "https://download.nomachine.com/download/10.2/Linux/nomachine-personal-edition_10.2.3_1_x86_64.tar.gz";
      hash = "sha256-cwHCG8SgdOjCZPNd3c1WFi+e0XRVJBCi6TTn2V8im44=";
    };
  });
}
