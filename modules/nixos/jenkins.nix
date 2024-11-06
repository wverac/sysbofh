{...}: {
  services.jenkins = {
    enable = true;
    port = 8181;
    withCLI = true;
  };
}
