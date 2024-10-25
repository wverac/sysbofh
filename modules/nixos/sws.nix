{...}: {
  services.static-web-server = {
    enable = true;
    listen = "[::]:8080";
    root = "/var/www";
    configuration = {
      general = {
        directory-listing = false;
      };
    };
  };
}
