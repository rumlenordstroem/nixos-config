{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.tuigreet;
in
{
  options.tuigreet  = {
    enable = mkEnableOption "Tuigreet display manager";

    package = mkPackageOption pkgs [ "tuigreet" ] { example = "pkgs.tuigreet"; };

    settings = { 
      args = mkOption {
        type = types.listOf types.str;
        default = [
          "--user-menu"
          "--remember"
          "--time"
          "--time-format '%Y-%m-%d %H:%M'"
          "--asterisks"
          "--cmd sway"
        ];
        description = ''
          Arguments to pass to the tuigreet binary.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    # Greeter before compositor
    services.greetd = {
      enable = true;
      # Tuigreet
      settings.default_session = {
        command = "${cfg.package}/bin/tuigreet ${concatStringsSep " " cfg.settings.args}";
        user = "greeter";
      };
        useTextGreeter = true;
    };

  # Fixes TTYs overriding. https://github.com/apognu/tuigreet/issues/17#issuecomment-927173694
   systemd.services.greetd.unitConfig.After = lib.mkOverride 0 [ "multi-user.target" ];
  };
}
