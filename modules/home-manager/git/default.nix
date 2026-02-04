{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.git;
in
{
  options.nix-pille.programs.git = {
    enable = mkEnableOption {
      name = "nix pille git configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      iniContent = {
        init.defaultBranch = "main";
      };
    };
  };
}
