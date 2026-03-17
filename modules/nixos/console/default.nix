{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.console;
in
{
  config = mkIf cfg.enable {
    console = {
      earlySetup = true;

      # Colors for TTY
      colors = with config.lib.stylix.colors; [
        base00 base08 base0B base0A base0D base0E base0C base05
        base03 base08 base0B base0A base0D base0E base0C base06
      ];

      font = mkDefault "${pkgs.terminus_font}/share/consolefonts/ter-116n.psf.gz";
    };
  };
}
