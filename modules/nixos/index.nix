{...}: let
  customPort = 8080;
in {
  options = {};
  config = {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "static-site" = {
          listen = [
            {
              addr = "0.0.0.0";
              port = customPort;
            }
          ];
          locations = {
            "/" = {
              extraConfig = ''
                default_type text/html;
                  return 200 '
                  <html>
                  <head><title>sysBOF</title></head>
                  <body><center>
                    <h1>B O F H</h1>
                    <p>got beer?</p>
                  <!-- Nothing to see here, this is a personal site with a lot of constantly moving garbage -->
                  <!-- if you are looking for NixOs resources visit: nixos.org -->
                  </center></body>
                  </html>';
              '';
            };
          };
        };
      };
    };

    networking.firewall.allowedTCPPorts = [customPort];
  };
}
