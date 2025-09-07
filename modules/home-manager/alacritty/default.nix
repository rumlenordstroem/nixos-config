{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.alacritty;
in
{
  options.nix-pille.programs.alacritty = {
    enable = mkEnableOption {
      name = "nix pille alacritty configuration";
    };
  };

  config = mkIf cfg.enable {
    # Set as default terminal
    home.sessionVariables.TERM = "alacritty";

    programs.alacritty = {
      enable = true;

      settings = {
        cursor = {
          blink_interval = 600;
          blink_timeout = 10;
          unfocused_hollow = false;
          style = {
            blinking = "On";
            shape = "Beam";
          };
        };
        font.size = 10.0; # TODO
        keyboard.bindings = [
          { key = "Return"; mods = "Super|Shift"; action = "SpawnNewInstance"; }
        ];
        scrolling = {
          history = 10000;
          multiplier = 5;
        };
        window = {
          dynamic_padding = true;
          dynamic_title = true;
          opacity = 1.0;
          padding = {
            x = 2;
            y = 0;
          };
        };
        colors = with config.colorScheme.palette; {
          primary = {
            foreground = "0x${base05}";
            background = "0x${base00}";
          };
          cursor = {
            text = "0x${base05}";
            cursor = "0x${base06}";
          };
          search = {
            matches = {
              foreground = "0x${base00}";
              background = "0x${base05}";
            };
            focused_match = {
              foreground = "0x${base00}";
              background = "0x${base0B}";
            };
          };
          footer_bar = {
            foreground = "0x${base00}";
            background = "0x${base05}";
          };
          hints = {
            start = {
              foreground = "0x${base00}";
              background = "0x${base0A}";
            };
            end = {
              foreground = "0x${base00}";
              background = "0x${base05}";
            };
          };
          selection = {
            text = "CellForeground";
            background = "0x${base03}";
          };
          normal = {
            black = "0x${base03}";
            red = "0x${base08}";
            green = "0x${base0B}";
            yellow = "0x${base0A}";
            blue = "0x${base0D}";
            magenta = "0x${base0E}";
            cyan = "0x${base0C}";
            white = "0x${base05}";
          };
          bright = {
            black = "0x${base04}";
            red = "0x${base08}";
            green = "0x${base0B}";
            yellow = "0x${base0A}";
            blue = "0x${base0D}";
            magenta = "0x${base0E}";
            cyan = "0x${base0C}";
            white = "0x${base05}";
          };
          dim = {
            black = "0x${base03}";
            red = "0x${base08}";
            green = "0x${base0B}";
            yellow = "0x${base0A}";
            blue = "0x${base0D}";
            magenta = "0x${base0E}";
            cyan = "0x${base0C}";
            white = "0x${base05}";
          };
        };     
      };
    };
  };
}
