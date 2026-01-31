{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking;
in
{
  options.networking.enable = mkEnableOption "Networking settings";

  config = mkIf cfg.enable {
    systemd.network = {
      enable = true;
      wait-online.enable = false;
      networks = {
        "20-wired" = {
          matchConfig.Name = "enp*";
          linkConfig.RequiredForOnline = "routable";
          networkConfig = {
            DHCP = "yes";
            MulticastDNS = true;
            LLMNR = "no";
          };
          dhcpV4Config.RouteMetric = 100;
          ipv6AcceptRAConfig.RouteMetric = 100;
        };
        "25-wireless" = {
          matchConfig.Name = "wlp*";
          linkConfig.RequiredForOnline = "routable";
          networkConfig = {
            DHCP = "yes";
            MulticastDNS = true;
            LLMNR = "no";
            IgnoreCarrierLoss = "3s";
          };
          dhcpV4Config.RouteMetric = 600;
          ipv6AcceptRAConfig.RouteMetric = 600;
        };
      };
      # Use predictable naming scheme
      links."80-iwd".linkConfig.NamePolicy = mkForce "database onboard slot path mac keep kernel";
    };

    networking = {
      # DHCP managed by networkd
      useDHCP = false;

      # Use nftables instead of legacy iptables
      nftables.enable = true;
      firewall = {
        enable = true;
        allowedUDPPorts = [
          5353 # MulticastDNS
        ];
      };

      # Wireless daemon
      wireless.iwd.enable = true;
    };

    # DNS
    networking.nameservers = [ "194.242.2.4#base.dns.mullvad.net" ];
    services.resolved.settings.Resolve.DNSOverTLS = "true";
  };
}
