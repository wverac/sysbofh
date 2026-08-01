{pkgs, ...}: {
  programs.captive-browser = {
    enable = true;
    bindInterface = false;
    interface = "";
    dhcp-dns = ''
      dev="$(${pkgs.networkmanager}/bin/nmcli -t -f DEVICE,TYPE,STATE dev \
        | ${pkgs.gawk}/bin/awk -F: '$2=="wifi" && $3=="connected"{print $1; exit}')"
      ${pkgs.networkmanager}/bin/nmcli dev show "$dev" | ${pkgs.gnugrep}/bin/fgrep IP4.DNS
    '';
  };
}
