{...}: {
  services.static-web-server = {
    enable = true;
    listen = "[::]:1337";
    root = "/var/www";
    configuration = {
      general = {
        directory-listing = false;
      };
    };
  };
}
