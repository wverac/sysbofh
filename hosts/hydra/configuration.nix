# Personal laptop, ASUS ProArt P14 (aarch64).
{
  config,
  lib,
  pkgs,
  ...
}: {
  imports = [
    # sudo nixos-generate-config --show-hardware-config > ./hosts/$hostname/hardware-configuration.nix
    ./hardware-configuration.nix
    ./n1x/kernel.nix
    ./n1x/gpu.nix
    ./n1x/audio.nix
    ./n1x/power.nix
    ../../modules/nixos/poweroptions.nix
    ../../modules/nixos/sddm.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/hypr.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/sound.nix
    #../../modules/nixos/libvirtd.nix
    ../../modules/nixos/cli-bundle.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/mullvad-tailscale-coexist.nix
    ../../modules/nixos/usbprinter.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/mullvad.nix
    ../../modules/nixos/nixvim.nix
    ../../modules/nixos/thunderbolt.nix
    ../../modules/nixos/ydotool.nix
    ../../modules/nixos/captive-portal.nix
    ../../modules/nixos/large-builds.nix
    ../../modules/nixos/rclone-mount.nix
    ../../modules/nixos/fail2ban.nix
    ../../modules/nixos/auditd.nix
    #../../modules/nixos/hydra-builder.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 20;
  boot.loader.efi.canTouchEfiVariables = false;

  # Console on the internal panel
  boot.kernelParams = [
    "console=tty0"
    "acpi=nospcr"
    "module_blacklist=nouveau,nvidiafb"
    # Do not wait for the TPM
    "systemd.tpm2_wait=0"
  ];
  boot.blacklistedKernelModules = ["nouveau" "nvidiafb"];

  # Disk encryption
  boot.initrd.luks.devices.cryptroot = {
    device = "/dev/disk/by-label/NEBU_CRYPT";
    allowDiscards = true;
  };
  services.fstrim.enable = true;
  fileSystems."/".options = ["noatime"];
  fileSystems."/home".options = ["noatime"];
  fileSystems."/home".neededForBoot = true;
  fileSystems."/data".options = ["noatime"];

  # Large console font
  console = {
    earlySetup = true;
    packages = [pkgs.terminus_font];
    font = "ter-v32n";
  };

  # Suspend only, no hibernation
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  # SDDM greeter on Wayland
  services.displayManager.sddm.wayland.enable = true;

  # Rootless Docker only for regular users
  systemd.user.services.docker.unitConfig.ConditionUser = lib.mkForce "!@system";

  # Sysctl hardening
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.log_martians" = 1;
    "kernel.kexec_load_disabled" = 1;
  };

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "hydra";

  # Enable systemd-resolved
  services.resolved.enable = true;

  # Enable cron
  services.cron.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "altgr-intl";
  };

  users.users = {
    "bofh" = {
      isNormalUser = true;
      description = "BOFH";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "docker"
      ];
      shell = pkgs.bash;
      ignoreShellProgramCheck = true;
      packages = [];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOD+PjILkShGsDvqChmZzVzDbExoENsKlsPEqHxnr4PN wv@linux.com"
      ];
    };
  };
  # sudo no passwd
  security.sudo = {
    enable = true;
    extraRules = [
      {
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
        users = ["bofh"];
      }
    ];
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
    # btop with GPU support
    overlays = [
      (final: prev: {
        btop = prev.btop.override {cudaSupport = true;};
      })
    ];
  };

  # gotop with GPU metrics
  environment.shellAliases.gotop = "gotop --nvidia";

  # The kernel is set in ./n1x/kernel.nix.
  hardware.enableAllFirmware = true;
  hardware.enableRedistributableFirmware = true;

  # Enable Flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
  environment.systemPackages = with pkgs; [
    # Flakes clones its dependencies through the git command,
    # so git must be installed first
    git
    vim
    wget
    curl
    jq
    nvme-cli
    efibootmgr
    (import ./slack.nix {inherit pkgs;})
  ];

  # SOPS
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/bofh/.config/sops/age/keys.txt";
  sops.secrets.tailscaleKey = {};
  sops.secrets.tailscaleHost = {};
  sops.secrets.rcloneMountRemote = {};
  sops.secrets.rcloneMountPoint = {};
  sops.secrets.rcloneConfig.owner = "bofh";

  # rclone remote mount
  services.rclone-mount = {
    enable = true;
    remoteSecretFile = config.sops.secrets.rcloneMountRemote.path;
    mountPointSecretFile = config.sops.secrets.rcloneMountPoint.path;
    configFile = config.sops.secrets.rcloneConfig.path;
    user = "bofh";
  };

  # No inbound remote login
  services.openssh.enable = false;
  programs.ssh.startAgent = true;
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.settings.KbdInteractiveAuthentication = false;

  # Set the default editor to vim
  environment.variables.EDITOR = "vim";

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Optimize storage
  nix.settings.auto-optimise-store = true;
  nix.settings.allowed-users = ["root" "@wheel"];

  system.stateVersion = "26.11";
}
