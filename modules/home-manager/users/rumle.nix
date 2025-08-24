{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.users.rumle;
in
{
  options.users.rumle.enable = mkEnableOption "Common options for rumle";


  config = mkIf cfg.enable {
    # Enable commonly used CLI tools
    cli.enable = true;

    home = {
      username = "rumle";
      homeDirectory = "/home/${config.home.username}";
    };

    # Enable XDG base directories management
    xdg.enable = true;
    nix = {
      enable = true;
      package = pkgs.nix;
    };

    # Enable home-manager
    programs.home-manager.enable = true;
    news.display = "show";

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";

    services.syncthing = {
      settings = {
        devices = {
          pixel.id = "M7FJDSU-6WUW5AV-RTNK4OE-XYJDKLQ-3XYHFX4-PSPRAUN-3ZSYIO6-U3K23AE";
          p43s.id = "RSCAZCQ-AIVEFTH-X2VQJJO-AARUEQG-NWGPV6V-U7VM64D-6FRBB5Q-GZWV6AV";
          edb.id = "57IKVA7-C7BDPIG-3FJ4X7I-5O7HZEV-N7AT62C-SERJBRQ-VTVP6JQ-BOWP7QW";
        };
      };
    };
  };
}
