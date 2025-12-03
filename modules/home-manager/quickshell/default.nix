{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.quickshell;
in
{
  options.nix-pille.programs.quickshell = {
    enable = mkEnableOption {
      name = "nix pille quickshell configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.quickshell = {
      enable = true;
      # systemd.enable = true;
      # configs = {};
    };
  };
}
