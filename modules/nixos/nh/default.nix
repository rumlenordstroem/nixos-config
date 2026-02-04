{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.nh;
in
{
  config = mkIf cfg.enable {
    programs.nh = {
      clean.enable = true;
      clean.extraArgs = "--keep-since 3d --keep 3";
    };
  };
}
