{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.fonts;
in
{
  options.nix-pille.fonts = {
    enable = mkEnableOption {
      name = "nix pille font configuration";
    };
  };

  config = mkIf cfg.enable {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "MesloLGLDZ Nerd Font" ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };

    home.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      nerd-fonts.meslo-lg
      ibm-plex
    ];
  };
}
