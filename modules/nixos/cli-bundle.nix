{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    neofetch
    inxi
    yazi
    ueberzugpp # alacritty support for yazi
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
    nix-bash-completions
    bash-completion
    coreutils
    # Add other packages you want to install
  ];
}
