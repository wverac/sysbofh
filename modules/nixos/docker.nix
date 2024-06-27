{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
}
