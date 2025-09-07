{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.bat;
in
{
  options.nix-pille.programs.bat = {
    enable = mkEnableOption {
      name = "nix pille bat configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config.theme = "base16";
    };
  };
}
