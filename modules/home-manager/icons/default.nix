{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.icons;
in
{
  options.nix-pille.icons = {
    enable = mkEnableOption "Icon theme module";

    package = mkPackageOption pkgs "icons" { example = "pkgs.papirus-icon-theme"; };

    name = mkOption {
      type = types.str;
      example = "Papirus-Dark";
      description = ''
        Name of the icon theme.
      '';
    };

    path = mkOption {
      type = types.path;
      apply = toString;
      example = "${cfg.package}/share/icons/${cfg.name}";
      description = ''
        Path to the icon theme.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # Dynamically set the `path` if it's not explicitly configured by the user
    nix-pille.icons.path = mkDefault "${cfg.package}/share/icons/${cfg.name}";
  };
}
