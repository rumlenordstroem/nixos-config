{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.gtk;
in
{
  options.nix-pille.gtk = {
    enable = mkEnableOption {
      name = "nix pille GTK configuration";
    };
  };

  config = mkIf cfg.enable {
    stylix.targets.gtk.enable = true;
    stylix.targets.gtk.fonts.enable = false;

    gtk = rec {
      enable = true;

      font = {
        name = head config.fonts.fontconfig.defaultFonts.sansSerif;
        size = 12;
      };

      iconTheme = { inherit (config.nix-pille.icons) name package; };

      gtk3 = {
        extraConfig.gtk-application-prefer-dark-theme = if config.lib.stylix.colors.variant == "dark" then "true" else "false";
      };
      gtk4.extraConfig = gtk3.extraConfig;
    };
  };
}
