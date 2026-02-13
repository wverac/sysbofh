{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nix-index
    inxi
    yazi
    ncdu
    ueberzugpp # alacritty support for yazi
    xorg.libXau # dependency of ueberzugpp
    libinput
    libinput-gestures
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
    autossh
    alejandra # nix code formatter
    shellcheck
    nix-bash-completions
    bash-completion
    coreutils
    wireguard-tools
    nftables
    iptables
    iproute2
    # Lab
    file
    terraform
    cdrtools
    ansible
    awscli
    libguestfs-with-appliance
    exfatprogs
    sshuttle
    bc
    sharutils
    lazygit
    gh
    hugo
    dart-sass
    cloudflared
    # LLM tools
    claude-code
    codex
    opencode
  ];
}
