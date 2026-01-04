{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.librewolf;
in {
  imports = [
    ./engines.nix
    ./settings.nix
    ./theme.nix
  ];

  options.nix-pille.programs.librewolf = {
    enable = mkEnableOption {
      name = "nix pille librewolf configuration";
    };
  };

  config = mkIf cfg.enable {
    # Set as default browser
    home.sessionVariables.BROWSER = "librewolf";
  
    programs.librewolf = {
      enable = true;

      profiles = {
        default = {
          isDefault = true;
  
          # Extentions must be manually enabled on first launch
          extensions = {
            force = true;
            packages = with pkgs.nur.repos.rycee.firefox-addons; [
              ublock-origin
              sponsorblock
              h264ify
              danish-dictionary
            ];
          };
        };
      };
    };
  };
}
