{...}: {
  # Enable avizo
  services.avizo.enable = true;
  services.avizo.settings = {
    default = {
      time = 1.0;
      y-offset = 0.5;
      fade-in = 0.1;
      fade-out = 0.2;
      padding = 10;
    };
  };
}
