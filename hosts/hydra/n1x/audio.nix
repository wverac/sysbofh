# Audio for the N1X platform, see ./SOURCES.md.
{
  lib,
  pkgs,
  ...
}: let
  # Speaker amplifier firmware.
  speakerFirmware = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "proart-p14-speaker-firmware";
    version = "1.0.678.52824";

    src = pkgs.fetchurl {
      name = "Audio_Driver_ARM_Cirrus_Z_V${version}Sub3_49783.exe";
      url = "https://dlcdnets.asus.com/pub/ASUS/nb/Image/Driver/Audio/49783/Audio_Driver_ARM_Cirrus_Z_V${version}Sub3_49783.exe?model=H7407BA";
      sha256 = "01ffa79558813cf9e943d63b4a39289471915ab865c32a1138ffe8382175355f";
    };

    nativeBuildInputs = [pkgs._7zz];
    dontUnpack = true;

    # Self extracting 7z archive.
    buildPhase = ''
      offset=$(LC_ALL=C grep -obUaP '7z\xBC\xAF\x27\x1C' $src | head -1 | cut -d: -f1)
      [ -n "$offset" ] || { echo "no 7z archive found in the installer" >&2; exit 1; }
      tail -c +$((offset + 1)) $src > driver.7z
      7zz x -y -odriver driver.7z > /dev/null
    '';

    installPhase = ''
      fw=driver/XU_Ext/fw/35L56/3.13.4/dflt
      tn=driver/XU_Ext/tn/35L56/33A1/dflt
      dest=$out/lib/firmware/cirrus
      base=cs35l56-b0-dsp1-misc-104333a1
      install -Dm444 $fw/b0_dflt_35l56_3.13.4.wmfw $dest/$base-spkid0.wmfw
      install -Dm444 $tn/b0_dflt_33a1_lw_l1u0.bin $dest/$base-spkid0-l1u0.bin
      install -Dm444 $tn/b0_dflt_33a1_rw_l1u1.bin $dest/$base-spkid0-l1u1.bin
      for f in .wmfw -l1u0.bin -l1u1.bin; do
        ln -s $base-spkid0$f $dest/$base-spkid1$f
      done
    '';

    meta = {
      description = "Cirrus CS35L56 amplifier firmware and tuning for the ASUS ProArt P14 H7407BA";
      license = lib.licenses.unfree;
      platforms = ["aarch64-linux"];
    };
  };

  # UCM profile of the sound card.
  ucmConf = pkgs.alsa-ucm-conf.overrideAttrs (old: {
    patches =
      (old.patches or [])
      ++ [
        (builtins.path {
          path = ./audio/alsa-ucm-conf-mt8901-soundwire.patch;
          name = "alsa-ucm-conf-mt8901-soundwire.patch";
        })
      ];
  });
in {
  hardware.firmware = [speakerFirmware];

  # Point ALSA at the patched profiles.
  environment.sessionVariables.ALSA_CONFIG_UCM2 = "${ucmConf}/share/alsa/ucm2";

  environment.systemPackages = [pkgs.alsa-utils];
}
