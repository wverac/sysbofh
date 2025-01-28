{...}: {
  services = {
    ollama = {
      enable = true;
      acceleration = false;
      openFirewall = true;
      # host = "127.0.0.1";
      # loadModels = [ "deepseek-r1" ];
    };

    open-webui = {
      enable = true;
      port = 1337;
    };
  };
}
