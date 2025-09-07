{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.eza;
in
{
  options.nix-pille.programs.eza = {
    enable = mkEnableOption {
      name = "nix pille eza configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
      extraOptions = [ "--time-style=long-iso" ];
    };
  };
}
