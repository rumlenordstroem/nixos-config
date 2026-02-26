{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.media-server;
in
{
  options.services.media-server.enable = mkEnableOption "Enable media server";

  config = mkIf cfg.enable {
    services.memos.enable = true;
    services.memos.openFirewall = true;

    nixarr = {
      enable = true;
      mediaDir = "/data/media";
      stateDir = "/data/media/.state/nixarr";

      # vpn = {
      #   enable = true;
      #   wgConf = "/data/.secret/wg.conf";
      # };

      transmission = {
        enable = true;
        # vpn.enable = true;
        # peerPort = 50000; # Set this to the port forwarded by your VPN
      };

      # It is possible for this module to run the *Arrs through a VPN, but it
      # is generally not recommended, as it can cause rate-limiting issues.
      # bazarr.enable = true;
      # lidarr.enable = true;
      prowlarr.enable = true;
      radarr.enable = true;
      # readarr.enable = true;
      sonarr.enable = true;
      jellyseerr.enable = true;
      jellyfin.enable = true;
    };

    # Allow connections with domain instead of hostname
    services.transmission.settings.rpc-host-whitelist = "${config.networking.hostName}.local";

    # Allow IPv6 connection to web UI
    services.transmission.settings.rpc-bind-address = lib.mkForce "0.0.0.0,::";



    services.flaresolverr.enable = true;

    # services.transmission = {
    #   enable = true;
    #   openFirewall = true;
    #   openRPCPort = true;
    #   settings = {
    #     rpc-enabled = true;
    #     rpc-bind-address = "0.0.0.0,::";
    #     rpc-whitelist-enabled = false;
    #     # rpc-whitelist = "${config.networking.hostName}.local";
    #     rpc-host-whitelist-enabled = false;
    #     # rpc-host-whitelist = "localhost,${config.networking.hostName}.local,${config.networking.hostName}";
    #   };
    # };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
      enable = true;
      virtualHosts."${config.networking.hostName}.local" = {
        sslCertificate = "/etc/ssl/certs/graaboellet.crt";
        sslCertificateKey = "/etc/ssl/private/graaboellet.key";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://localhost:${toString config.services.homepage-dashboard.listenPort}";
        };
      };
    };

    services.homepage-dashboard = {
      enable = true;
      openFirewall = true;
      allowedHosts = "${config.networking.hostName}.local";
      settings = {
        title = "Gråbøllet";
        background = {
          # image = "https://www.phoenixcopenhagen.com/dfsmedia/baeefe6bma74df44be8a2bccfb2c57af8e/418-source/cropsize/1540x866/outputimageformat/AvifImageFormat";
          image = "https://premium.vgc.no/v2/images/7e9a2aa3-21f2-4f18-9ada-0823f51c4486?fit=crop&format=auto&h=1367&w=2048&s=3a80c2e0dc42ab91fa9d4ffa62ebcda1605f9084";
          opacity = 20;
        };
        hideVersion = "true";
        layout = [
          {
            Media = {
              header = true;
              style = "column";
            };
          }
          {
            Servarr = {
              header = true;
              style = "column";
            };
          }
          {
            Downloads = {
              header = true;
              style = "column";
            };
          }
        ];
      };
      widgets = [
        {
          greeting = {
            text_size = "4xl";
            text = "Velkommen til Gråbøllets medieserver";
          };
        }
        # {
        #   logo.icon = "https://upload.wikimedia.org/wikipedia/commons/d/df/Sofie_Gr%C3%A5b%C3%B8l.jpg";
        # }
        {
          resources = {
            cpu = true;
            disk = [ "/" "/data"];
            memory = true;
            uptime = true;
            network = true;
          };
        }
        {
          openmeteo = {
            label = "Nyhavn";
            latitude = 55.674497302;
            longitude = 12.587664316;
            units = "metric";
          };
        }
      ];
      services = [
        {
          "Media" = [
            {
              "Jellyseerr" = {
                description = "Media request management";
                # href = "http://jellyseerr.${config.networking.hostName}.local";
                href = "http://${config.networking.hostName}.local:${toString config.services.jellyseerr.port}";
                icon = "sh-jellyseerr";
              };
            }
            {
              "Jellyfin" = {
                description = "Watch TV series and movies";
                # href = "http://jellyfin.${config.networking.hostName}.local";
                href = "http://${config.networking.hostName}.local:8096";
                icon = "sh-jellyfin";
              };
            }
            {
              "Memos" = {
                description = "Take notes and share your thoughts";
                # href = "http://memos.${config.networking.hostName}.local";
                href = "http://${config.networking.hostName}.local:${toString config.services.memos.settings.port}";
                icon = "sh-memos";
              };
            }
          ];
        }
        {
          "Servarr" = [
            {
              "Radarr" = {
                description = "Movie collection manager";
                # href = "http://radarr.${config.networking.hostName}.local";
                href = "http://${config.networking.hostName}.local:${toString config.services.radarr.settings.server.port}";
                icon = "radarr";
              };
            }
            {
              "Sonarr" = {
                description = "TV series collection manager";
                # href = "http://sonarr.${config.networking.hostName}.local";
                href = "http://${config.networking.hostName}.local:${toString config.services.sonarr.settings.server.port}";
                icon = "sonarr";
              };
            }
            {
              "Bazarr" = {
                description = "Subtitles collection manager";
                # href = "http://bazarr.${config.networking.hostName}.local";
                href = "http://${config.networking.hostName}.local:${toString config.services.bazarr.listenPort}";
                icon = "bazarr";
              };
            }
            {
              "Prowlarr" = {
                description = "Indexer manager and proxy";
                # href = "http://prowlarr.${config.networking.hostName}.local";
                href = "http://${config.networking.hostName}.local:${toString config.services.prowlarr.settings.server.port}";
                icon = "prowlarr";
              };
            }
          ];
        }
        {
          "Downloads" = [
            {
              "Transmission" = {
                description = "BitTorrent client";
                # href = "http://transmission.${config.networking.hostName}.local";
                href = "http://${config.networking.hostName}.local:${toString config.services.transmission.settings.rpc-port}";
                icon = "transmission";
              };
            }
          ];
        }
      ];
    };
  };
}
