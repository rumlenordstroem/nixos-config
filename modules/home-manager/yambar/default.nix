{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.yambar;
in
{
  options.nix-pille.programs.yambar = {
    enable = mkEnableOption {
      name = "nix pille yambar configuration";
    };
  };

  config = mkIf cfg.enable {
    # User configuration begins here
    programs.yambar = {
      enable = true;

      systemd.enable = true;

      settings = with config.colorScheme.palette; let
        # The scale value is manually used since yambar does not support automatic DPI scaling
        # This function scales an integer by the monitor scaling. Returns result as a string which yambar accepts
        scaledInt = n: strings.toInt (head (strings.splitString "." (strings.floatToString ((head (filter (m: m.primary) config.nix-pille.monitors)).scale * n))));

        # Main monitor where bar will be put
        monitor = (head (filter (m: m.primary) config.nix-pille.monitors)).name;

          # Default font (TODO)
        font = "monospace:pixelsize=${toString (scaledInt 14)}";
      in {
        bar = {
          # But bar on primary display
          inherit monitor font;
          location = "top";
          margin = scaledInt 15;
          spacing = scaledInt 10;
          height = scaledInt 26;
          foreground = "${base05}ff";
          background = "${base00}ff";

          border = {
            color = "${base04}ff";
            margin = mkDefault (scaledInt 6);
            bottom-margin = mkDefault (scaledInt 0);
            width = scaledInt 2;
          };

          left = [
            {
              # i3 modules can be used for sway
              i3 = {
                persistent = [ 1 2 3 4 5 ];
                spacing = config.programs.yambar.settings.bar.spacing;

                content."".map.conditions = let
                  mkSwayString = s: {
                    text = s;
                    on-click = "${config.wayland.windowManager.sway.package}/bin/swaymsg --quiet workspace {name}";
                  };
                in {
                  "state == focused" = { string = mkSwayString "󱓻 "; };
                  "state == invisible" = { string = mkSwayString "󱓼 "; };
                  "state == unfocused" = { string = mkSwayString "󱓼 "; };
                  "state == urgent" = { string = mkSwayString "󱓼 "; };
                };
              };
            }
          ];

          right = [
            {
              # TODO (remove or rewrite)
              removables = {
                spacing = 5;
                content = {
                  map = {
                    conditions = {
                      mounted = {
                        map = {
                          conditions = {
                            optical = [
                              {
                                string = {
                                  deco = {
                                    underline = {
                                      color = "ff0000ff";
                                      size = 4;
                                    };
                                  };
                                  text = " ";
                                };
                              }
                              {string = {text = "{label}";};}
                            ];
                            "~optical" = [
                              {
                                string = {
                                  deco = {
                                    underline = {
                                      color = "ff0000ff";
                                      size = 4;
                                    };
                                  };
                                  text = "r ";
                                };
                              }
                              {string = {text = "{label}";};}
                            ];
                          };
                          on-click = "udisksctl unmount -b {device}";
                        };
                      };
                      "~mounted" = {
                        map = {
                          conditions = {
                            optical = [
                              {
                                string = {
                                  text = " ";
                                };
                              }
                              {string = {text = "{label}";};}
                            ];
                            "~optical" = [
                              {
                                string = {
                                  text = "󱊞 ";
                                };
                              }
                              {string = {text = "{label}";};}
                            ];
                          };
                          on-click = "udisksctl mount -b {device}";
                        };
                      };
                    };
                  };
                };
              };
            }

            {
              # Display sway mode information
              i3.content = {
                # Just make it empty for all additional workspaces
                "".map = {
                  default = { string.text = ""; };
                  conditions = { };
                };

                # Display when mode is active
                current.map = {
                  default = { string.text = ""; };
                  conditions = {
                    "mode == resize" = { string.text = "󰲏 "; };
                  };
                };
              };
            }

            {
              pipewire = {
                # Only show module when there is no sound
                content.map = {
                  default = { string.text = ""; };
                  conditions = {
                    "muted" = { string.text = "󰖁 "; };
                  };
                };
              };
            }

            {
              network = {
                poll-interval = 5000;

                content.map = {
                  default = { empty = {}; };
                  conditions."name == wlp0s20f3".map = {
                    default = { string.text = ""; };
                    conditions = {
                      "state == down" = { string.text = "󰤯 "; };
                      "state == up" = { string.text = " "; };
                    };
                  };
                };
              };
            }

            {
              battery = {
                name = "BAT0";
                poll-interval = 5000;

                content.map = {
                  conditions = let
                    charging = [ "󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅" ];
                    discharging = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
                    not-charging = discharging;
                    unknown = charging;
                    mkBatRamp = texts: [ {
                      ramp = {
                        items = map (text: { string = { inherit text; }; }) texts;
                        tag = "capacity";
                      };
                    } ];
                  in {
                    "state == \"not charging\"" = mkBatRamp not-charging;
                    "state == charging" = mkBatRamp charging;
                    "state == discharging" = mkBatRamp discharging;
                    "state == unknown" = mkBatRamp unknown;
                    "state == full" = [ { string.text = lists.last charging; } ];
                  };
                };
                };
            }

            {
              clock = {
                date-format = "%Y-%m-%d";
                time-format = "%H:%M";
                content = [ { string.text = "{date} {time}"; } ];
              };
            }
          ];
        };
      };
    };
  };
}
