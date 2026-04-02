{...}: {
  # Kernel audit subsystem
  security.audit = {
    enable = true;
    rules = [
      # Privilege escalation: monitor sudo, su, setuid/setgid changes
      "-a always,exit -F arch=b64 -S execve -F path=/run/wrappers/bin/sudo -k privilege_escalation"
      "-a always,exit -F arch=b64 -S execve -F path=/run/wrappers/bin/su -k privilege_escalation"
      "-a always,exit -F arch=b64 -S setuid -S setgid -S setreuid -S setregid -k privilege_change"

      # Identity & authentication changes
      "-w /etc/passwd -p wa -k identity"
      "-w /etc/shadow -p wa -k identity"
      "-w /etc/group -p wa -k identity"
      "-w /etc/sudoers -p wa -k sudo_changes"
      "-w /etc/sudoers.d/ -p wa -k sudo_changes"
      "-w /etc/pam.d/ -p wa -k pam_changes"

      # SSH and secrets access
      "-w /etc/ssh/sshd_config -p wa -k sshd_config"
      "-w /etc/ssh/ -p wa -k ssh_keys"

      # Kernel module operations
      "-a always,exit -F arch=b64 -S init_module -S finit_module -S delete_module -k kernel_modules"

      # Firewall changes
      "-a always,exit -F arch=b64 -S execve -F path=/run/current-system/sw/bin/iptables -k firewall"
      "-a always,exit -F arch=b64 -S execve -F path=/run/current-system/sw/bin/nft -k firewall"

      # Suspicious execution from temp dirs
      "-a always,exit -F arch=b64 -S execve -F dir=/tmp -k temp_exec"
      "-a always,exit -F arch=b64 -S execve -F dir=/dev/shm -k temp_exec"
    ];
  };

  # Userspace audit daemon (log persistence)
  security.auditd.enable = true;
}
