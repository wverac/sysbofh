{pkgs, ...}: {
  imports = [
    # sudo nixos-generate-config --show-hardware-config > ./hosts/$hostname/hardware-configuration.nix
    ./hardware-configuration.nix
    #../../modules/nixos/zen-kernel.nix
    #../../modules/nixos/hibernate.nix
    ../../modules/nixos/poweroptions.nix
    ../../modules/nixos/sddm.nix
    ../../modules/nixos/fonts.nix
    ../../modules/nixos/hypr.nix
    ../../modules/nixos/bluetooth.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/libvirtd.nix
    ../../modules/nixos/cli-bundle.nix
    ../../modules/nixos/tailscale.nix
    ../../modules/nixos/keyd.nix
    #../../modules/nixos/laptop.nix
    ../../modules/nixos/auto-cpufreq.nix
    ../../modules/nixos/usbprinter.nix
    #../../modules/nixos/system76-lemp13b.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostName = "sysbofh"; # Define your hostname.

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
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
  };

  # Latest Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
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
  ];

  # SOPS
  sops.defaultSopsFile = ./secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/bofh/.config/sops/age/keys.txt";
  sops.secrets.tailscaleKey = {}; # tailscale service
  sops.secrets.exitNode = {}; # tailscale exit node

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  programs.ssh.startAgent = true;
  services.openssh.settings.PermitRootLogin = "no";

  # Set the default editor to vim
  environment.variables.EDITOR = "vim";

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Optimize storage
  # You can also manually optimize the store via:
  #    nix-store --optimise
  # Refer to the following link for more details:
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
