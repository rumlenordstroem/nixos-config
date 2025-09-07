{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.services.dunst;
in
{
  options.nix-pille.services.dunst = {
    enable = mkEnableOption {
      name = "nix pille dunst configuration";
    };
  };

  config = mkIf cfg.enable {
    # For notification binaries
    home.packages = [ pkgs.libnotify ];

    # Dunst configuration
    services.dunst = {
      enable = true;
      settings = {
        global = {
          follow = "mouse";
          width = 300;
          height = "(0, 200)";
          origin = "top-right";
          offset = "6x6";
          notification_limit = 0;
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 220;
          progress_bar_max_width = 300;
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;
          frame_width = 2;
          gap_size = 0;
          separator_color = "frame";
          font = "monospace 9"; # TODO
          markup = "full";
          enable_recursive_icon_lookup = true;
          icon_theme = config.nix-pille.icons.name;
          icon_path = lib.mkForce "";
          browser = "${pkgs.xdg-utils}/bin/xdg-open";
          corner_radius = 0;
        };


        urgency_low = with config.colorScheme.palette; {
          background = "#${base00}";
          foreground = "#${base05}";
          highlight = "#${base04}";
          frame_color = "#${base04}";
          timeout = 5;
        };

        urgency_normal = with config.colorScheme.palette; {
          background = "#${base00}";
          foreground = "#${base05}";
          highlight = "#${base04}";
          frame_color = "#${base04}";
          timeout = 5;
        };

        urgency_critical = with config.colorScheme.palette; {
          background = "#${base00}";
          foreground = "#${base05}";
          highlight = "#${base04}";
          frame_color = "#${base09}";
          timeout = 0;
        };
      };
    };
  };
}
