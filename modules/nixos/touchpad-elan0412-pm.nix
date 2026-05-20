{...}: {
  # Workaround for ELAN0412 I2C-HID touchpad firmware hang on Lemur Pro.
  # The controller occasionally stops emitting HID reports while the kernel
  # bus remains healthy; recovery requires a real power cycle (S3 suspend).
  # Disabling runtime PM on the I2C device avoids the PM transition that
  # appears to trigger the firmware state corruption.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="i2c", KERNEL=="i2c-ELAN0412:00", ATTR{power/control}="on"
  '';
}
