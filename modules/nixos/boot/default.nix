{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.boot;
in
{
  options.boot.enable = mkEnableOption "Boot settings";

  config = mkIf cfg.enable {
    boot.loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };
  };
}
