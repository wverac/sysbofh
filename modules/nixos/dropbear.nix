{
  pkgs,
  config,
  ...
}: {
  boot.kernelParams = ["ip=dhcp"];
  boot.initrd = {
    availableKernelModules = ["r8169"];
    systemd.users.root.shell = "/bin/cryptsetup-askpass";
    network = {
      enable = true;
      ssh = {
        enable = true;
        port = 31337;
        authorizedKeys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOD+PjILkShGsDvqChmZzVzDbExoENsKlsPEqHxnr4PN wv@linux.com"];
        hostKeys = ["/etc/secrets/initrd/ssh_host_rsa_key"];
      };
      postCommands = ''
        echo 'cryptsetup-askpass' >> /root/.profile
      '';
    };
  };
}
