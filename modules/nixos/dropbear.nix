{
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd = {
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 31337;
        authorizedKeys = [
          ''command="systemctl default",no-port-forwarding,no-agent-forwarding,no-X11-forwarding ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOD+PjILkShGsDvqChmZzVzDbExoENsKlsPEqHxnr4PN wv@linux.com''
        ];
        hostKeys = ["/etc/secrets/initrd/ssh_host_rsa_key"];
      };
    };
  };
}
