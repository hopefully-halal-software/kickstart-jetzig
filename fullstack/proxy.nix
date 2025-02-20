# بسم الله الرحمن الرحيم
# la ilaha illa Allah Mohammed Rassoul Allah


# HOW TO USE:
#
# paste this in your /etc/nixos/configuration.nix
# or in a seperate module :)

services.nginx = {
  enable = true;

  # Recommended settings from the NixOS wiki
  recommendedProxySettings = true;  # Adds common security & performance settings
  # recommendedGzipSettings = true;   # Enables gzip compression
  recommendedOptimisation = true;   # Tweaks worker processes and caching
  # recommendedTlsSettings = true;    # Applies secure TLS settings (if using HTTPS)

  virtualHosts."proxy" = {
    listen = [
      {
        addr = "127.0.0.1";
        port = 12000;
      }
    ];

    # Proxy configuration for main backend
    locations."/" = {
      proxyPass = "http://localhost:8080";

      extraConfig = ''
        proxy_intercept_errors on;
        error_page 404 502 503 @svelte;
        if ($request_method !~ ^(GET|HEAD)$) {
          proxy_pass http://localhost:8080;
          break;
        }
        try_files $uri @backend @svelte;
      '';
    };

    locations."/api" = {
      proxyPass = "http://localhost:8080";
    };

    locations."@backend" = {
      proxyPass = "http://localhost:8080";
    };

    # Fallback location for the second backend
    locations."@svelte" = {
      proxyPass = "http://localhost:5173";
       extraConfig = ''
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "Upgrade";
      '';
    };
  };
};
