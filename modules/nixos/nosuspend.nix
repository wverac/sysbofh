{lib, ...}: {
  # sleep instead of suspend (testing)
  powerManagement.enable = lib.mkForce false;
  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
}
