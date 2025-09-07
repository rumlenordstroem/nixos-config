{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.services.gammastep;
in
{
  options.nix-pille.services.gammastep = {
    enable = mkEnableOption {
      name = "nix pille gammastep configuration";
    };
  };

  config = mkIf cfg.enable {
    services.gammastep = {
      enable = true;

      provider = "manual";
      temperature = {
        day = 6500;
        night = 1800;
      };
      settings.general = {
        dusk-time = "21:00-23:00";
        dawn-time = "06:00-07:00";
        fade = 1;
        adjustment-method = "wayland";
      };
    };
  };
}
