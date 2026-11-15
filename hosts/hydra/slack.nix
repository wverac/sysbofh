# Slack desktop for aarch64-linux.
{pkgs}: let
  version = "4.53.287";
  utilsVersion = "1.27.0";
  electron = pkgs.electron_45-bin;

  # Native helper, aarch64 build.
  desktopUtils = pkgs.fetchurl {
    url = "https://slack-desktop-native-prebuilds.s3.amazonaws.com/slackdesktoputils-v${utilsVersion}-napi-v8-linux-arm64.tar.gz";
    sha256 = "533e4e54c27657f7934019d875193b5e25828dad7e352d3fbf538540aae8f712";
  };
in
  pkgs.stdenv.mkDerivation {
    pname = "slack";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://downloads.slack-edge.com/desktop-releases/linux/x64/${version}/slack-desktop-${version}-amd64.deb";
      sha256 = "c2057f221e41275b7eadc5b658edc00289466b6fb55c912c5894831f6900f969";
    };

    nativeBuildInputs = with pkgs; [dpkg asar jq makeWrapper patchelf wrapGAppsHook3 file];
    buildInputs = with pkgs; [gtk3];

    dontUnpack = true;
    dontBuild = true;
    dontWrapGApps = true;
    # The copied runtime is already patched.
    dontPatchELF = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      dpkg --fsys-tarfile $src | tar --extract

      # Same Electron major as the application.
      want=$(cut -d. -f1 usr/lib/slack/version)
      have=${pkgs.lib.versions.major electron.version}
      [ "$want" = "$have" ] || { echo "Slack wants Electron $want, got $have" >&2; exit 1; }

      # Runtime and application.
      mkdir -p $out/lib/slack
      cp -r ${electron}/libexec/electron/. $out/lib/slack/
      chmod -R u+w $out/lib/slack
      rm -f $out/lib/slack/resources/default_app.asar
      app=$out/lib/slack/resources/app
      asar extract usr/lib/slack/resources/app.asar $app
      find usr/lib/slack/resources -maxdepth 1 -type f ! -name app.asar \
        -exec cp -t $out/lib/slack/resources {} +

      # Helper version must match.
      wantUtils=$(jq -r .version $app/node_modules/@tinyspeck/slack-desktop-utils/package.json)
      [ "$wantUtils" = "${utilsVersion}" ] || { echo "Slack wants slack-desktop-utils $wantUtils, got ${utilsVersion}" >&2; exit 1; }

      # Known x86_64 modules only, an unknown one fails the build.
      for m in \
        @tinyspeck/native-keymap/build/Release/keymapping.node \
        @tinyspeck/slack-desktop-utils/lib/binding/napi-v8/slackdesktoputils.node \
        cf-prefs/build/Release/cf-prefs.node \
        electron-native-auth/build/Release/electron_native_auth.node \
        file-handler-info/build/Release/file_handler_info.node \
        macos-notification-state/build/Release/notificationstate.node \
        registry-js/build/Release/registry.node \
        windows-focus-assist/build/Release/focusassist.node; do
        rm $app/node_modules/$m
      done
      left=$(find $app -name '*.node')
      [ -z "$left" ] || { echo "unknown native module: $left" >&2; exit 1; }

      tar -xzf ${desktopUtils}
      install -Dm755 napi-v8/slackdesktoputils.node \
        $app/node_modules/@tinyspeck/slack-desktop-utils/lib/binding/napi-v8/slackdesktoputils.node
      patchelf --set-rpath ${pkgs.lib.makeLibraryPath [pkgs.stdenv.cc.cc.lib]} \
        $app/node_modules/@tinyspeck/slack-desktop-utils/lib/binding/napi-v8/slackdesktoputils.node

      cat > $app/node_modules/file-handler-info/index.js <<'EOF'
      module.exports = { getHandlerInfo: () => ({ friendlyName: null, handlerPath: null }) };
      EOF
      cat > $app/node_modules/electron-native-auth/index.js <<'EOF'
      class AuthRequest {
        static isAvailable() {
          return false;
        }
        constructor() {
          throw new Error("not implemented on this platform");
        }
      }
      module.exports = { AuthRequest };
      EOF
      cat > $app/node_modules/@tinyspeck/native-keymap/index.js <<'EOF'
      module.exports = {
        getCurrentKeyboardLayout: () => null,
        getKeyMap: () => [],
        onDidChangeKeyboardLayout: () => {},
        isISOKeyboard: () => false,
        ignoreAllEvents: () => {},
      };
      EOF

      if find $app -type f -exec file {} + | grep -q 'x86-64'; then
        echo "x86_64 binary left in the application" >&2
        exit 1
      fi

      install -Dm644 usr/share/pixmaps/slack.png $out/share/icons/hicolor/512x512/apps/slack.png
      install -Dm644 usr/share/applications/slack.desktop $out/share/applications/slack.desktop
      substituteInPlace $out/share/applications/slack.desktop \
        --replace-fail /usr/bin/slack "$out/bin/slack -s" \
        --replace-fail /usr/share/pixmaps/slack.png slack

      runHook postInstall
    '';

    postFixup = ''
      makeWrapper $out/lib/slack/electron $out/bin/slack \
        "''${gappsWrapperArgs[@]}" \
        --suffix PATH : ${pkgs.lib.makeBinPath [pkgs.xdg-utils]} \
        --add-flags "--ozone-platform=wayland --enable-features=WaylandWindowDecorations,WebRTCPipeWireCapturer --enable-wayland-ime"
    '';

    meta = {
      description = "Slack desktop on the aarch64 Electron of nixpkgs";
      license = pkgs.lib.licenses.unfree;
      platforms = ["aarch64-linux"];
      mainProgram = "slack";
    };
  }
