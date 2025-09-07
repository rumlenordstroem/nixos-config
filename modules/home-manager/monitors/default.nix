{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.monitors;
in
{
  options.nix-pille.monitors = mkOption {
    type = types.listOf (types.submodule {
      options = {
        name = mkOption {
          type = types.str;
          example = "DP-1";
        };
        primary = mkOption {
          type = types.bool;
          default = false;
        };
        width = mkOption {
          type = types.int;
          example = 1920;
        };
        height = mkOption {
          type = types.int;
          example = 1080;
        };
        refreshRate = mkOption {
          type = types.float;
          default = 60.0;
        };
        x = mkOption {
          type = types.int;
          default = 0;
        };
        y = mkOption {
          type = types.int;
          default = 0;
        };
        scale = mkOption {
          type = types.float;
          default = 1.0;
        };
      };
    });
    default = [ ];
  };

  config = {
    assertions = [{
      assertion = ((lib.length cfg) != 0) ->
        ((lib.length (lib.filter (m: m.primary) cfg)) == 1);
      message = "Exactly one monitor must be set to primary.";
    }];
  };
}
