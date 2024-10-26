{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nix-index
    fastfetch
    inxi
    yazi
    ueberzugpp # alacritty support for yazi
    xorg.libXau # dependency of ueberzugpp
    tree
    killall
    ethtool
    pciutils
    usbutils
    which
    nmap
    gnupg
    dnsutils
    gotop
    iperf3
    openvpn
    mtr
    lm_sensors
    btop
    p7zip
    alejandra # nix code formatter
    shellcheck
    nix-bash-completions
    bash-completion
    coreutils
    # Lab
    terraform
    cdrtools
    ansible
    awscli
    libguestfs-with-appliance
  ];
}
