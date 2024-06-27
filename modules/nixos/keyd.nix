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
