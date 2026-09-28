{pkgs, ...}: {
  # Printing service for Canon Pixma TS202 USB
  services.printing.enable = true;
  services.printing.drivers = [pkgs.cnijfilter2];
  environment.systemPackages = with pkgs; [cups];

  # The queue used to exist only as mutable state in /etc/cups, so a reinstall
  # lost it. Declared here instead. The serial pins the URI to this printer,
  # and canonts200.ppd comes from cnijfilter2 above.
  hardware.printers = {
    ensureDefaultPrinter = "Pixma";
    ensurePrinters = [
      {
        name = "Pixma";
        description = "Canon Pixma TS200 series over USB";
        deviceUri = "usb://Canon/TS200%20series?serial=248148";
        model = "canonts200.ppd";
        ppdOptions.print-color-mode = "monochrome";
      }
    ];
  };
}
