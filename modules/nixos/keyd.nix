{pkgs, ...}: let
  keydConf = ''
    [ids]
    *
    [main]
    f2 = micmute
    f3 = mute
    f5 = volumedown
    f6 = volumeup
    f8 = brightnessdown
    f9 = brightnessup
    pageup = left
    pagedown = right
    capslock = layer(nav)
    [nav]
    pagedown = pagedown
    pageup = pageup
    h = left
    k = up
    j = down
    l = right
  '';
in {
  systemd.services.keyd = {
    description = "Wayland key remapping daemon";
    enable = true;
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.keyd}/bin/keyd";
      Restart = "always";
    };
    wantedBy = ["sysinit.target"];
    requires = ["local-fs.target"];
    after = ["local-fs.target"];
  };
  environment.etc."keyd/default.conf".text = keydConf;
  environment.systemPackages = with pkgs; [keyd];
}
