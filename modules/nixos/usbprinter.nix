{pkgs, ...}: {
  # Printing service for Canon Pixma TS202 USB
  services.printing.enable = true;
  # services.printing.drivers = [pkgs.cnijfilter2];
  # TODO: temporary workaround for C23 compatibility issue where 'bool' is now a keyword
  # Remove this override once cnijfilter2 is fixed upstream in nixpkgs
  services.printing.drivers = [
    (pkgs.cnijfilter2.overrideAttrs (old: {
      env.NIX_CFLAGS_COMPILE = toString (old.env.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
    }))
  ];
  environment.systemPackages = with pkgs; [cups];
}
