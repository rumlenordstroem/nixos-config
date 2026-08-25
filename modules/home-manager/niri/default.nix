{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.niri;
in
{
  options.nix-pille.programs.niri = {
    enable = mkEnableOption {
      name = "nix pille niri configuration";
    };
  };

  config = mkIf cfg.enable {
    nix-pille.programs = {
      fuzzel.enable = true;        # Menu
      swaylock.enable = true;      # Screen locker (systemd service)
      yambar.enable = true;        # Status bar (systemd service)
      quickshell.enable = true;    # Widget toolkit
    };

    nix-pille.services = {
      dunst.enable = true;         # Notification daemon (systemd service)
      gammastep.enable = true;     # Color temperature adjuster (systemd service)
      swayidle.enable = true;      # Inactivity manager (systemd service)
    };

    services.playerctld.enable = true;    # Playerctl for controlling media

    home.packages = with pkgs; [
      wl-clipboard       # Copy paste utils
      xdg-utils          # Useful desktop CLI tools
    ];

    # XDG desktop integration
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-wlr ];
      config.common = {
        default = "gtk";
        "org.freedesktop.impl.portal.Screenshot" = "wlr";
        "org.freedesktop.impl.portal.ScreenCast" = "wlr";
      };
    };

    # System icon theme
    nix-pille.icons = {
      enable = true;
      package = pkgs.papirus-icon-theme.overrideAttrs (oldAttrs: {
        patchPhase = /* sh */ ''
          find . -type f -name "*.svg" -exec sed -i 's/#${if config.lib.stylix.colors.variant == "dark" then "dfdfdf" else "444444"}/#${config.lib.stylix.colors.base05}/g' {} +
        '';
        dontPatchELF = true;
        dontPatchShebangs = true;
        dontRewriteSymlinks = true;
      });
      name = if config.lib.stylix.colors.variant == "dark" then "Papirus-Dark" else "Papirus-Light";
    };

    # System cursor theme
    home.pointerCursor = {
      enable = true;
      package = pkgs.capitaine-cursors;
      name = if config.lib.stylix.colors.variant == "dark" then "capitaine-cursors-white" else "capitaine-cursors";
      size = 32;
      gtk.enable = true;
    };

    services.awww.enable = true;

    # Niri config
    wayland.windowManager.niri.enable = true;
    wayland.windowManager.niri.settings =

    let
      # Essentials
      lock = "${pkgs.systemd}/bin/loginctl lock-session";
      awww = "${config.services.awww.package}/bin/awww";
      cut = "${pkgs.coreutils}/bin/cut";
      terminal = "${config.programs.alacritty.package}/bin/alacritty";
      launcher = "${config.programs.fuzzel.package}/bin/fuzzel";
      finder = "${pkgs.fd}/bin/fd --type file|${launcher} --dmenu|${pkgs.findutils}/bin/xargs -I {} ${pkgs.xdg-utils}/bin/xdg-open '{}'";
      playerctl = "${config.services.playerctld.package}/bin/playerctl";
      grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
      kbd-brightness-control = "${pkgs.kbd-brightness-control}/bin/kbd-brightness-control";
      audio-volume-control = "${pkgs.audio-volume-control}/bin/audio-volume-control";
      mon-brightness-control = "${pkgs.mon-brightness-control}/bin/mon-brightness-control";

      scrollCoolDown = 200;

    in {
      input.keyboard = {
        xkb = {
          options = "lv3:ralt_switch,grp:alt_caps_toggle";
        };
      };

      input.mouse = {
        accel-profile = "flat";
        accel-speed = -0.35;
      };

      input.touchpad = {
        accel-profile = "adaptive";
        accel-speed = 0.20;
        scroll-factor = 0.35;
        # tap = false;
        # dwt = false;
        natural-scroll = {};
        click-method = "clickfinger";
      };

      # No client side decorations
      prefer-no-csd = true;

      # Cursor settings
      cursor = {
        xcursor-size = config.home.pointerCursor.size;
        xcursor-theme = config.home.pointerCursor.name;
      };

      environment = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      layout = {
        gaps = 6;
        border = with config.lib.stylix.colors; {
          on = {};
          width = 2;
          active-color = "#${base07}";
          inactive-color = "#${base04}";
        };

        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };

        focus-ring.off = {};

        tab-indicator = with config.lib.stylix.colors; {
          active-color = "#${base0E}";
          inactive-color = "#${base07}";
          urgent-color = "#${base08}";
          width = 2;
          gap = -2;
          length._props.total-proportion = 1.0;
        };

        background-color = "transparent";
      };

      _children = [
        { window-rule._children = [
          { geometry-corner-radius = 8; }
          { clip-to-geometry = true; }
        ];}

        { layer-rule._children = [
          { match._props = { namespace = "^awww-daemon$"; }; }
          { place-within-backdrop = true; }
        ];}
      ] ++ map(monitor: {
        output = {
          _args = [ monitor.name ];
          mode = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}";
          scale = monitor.scale;
          position._props = {
            x = monitor.x;
            y = monitor.y;
          };
        };
      }) (config.nix-pille.monitors);

      animations = {
        workspace-switch = {
          spring._props = {
            damping-ratio = 1.0;
            stiffness = 500;
            epsilon = 0.0001;
          };
        };

        window-open = {
          duration-ms = 250;
          curve = "ease-out-quad";
          custom-shader = /* glsl */ ''
            vec4 crt_power_on(vec3 coords_geo, vec3 size_geo) {
                float p = niri_clamped_progress;

                float scale_x = min(1.0, p * 1.5);
                float scale_y = mix(0.005, 1.0, pow(p, 3.0));

                vec2 coords = coords_geo.xy - 0.5;
                coords.x /= scale_x;
                coords.y /= scale_y;
                coords += 0.5;

                if (coords.x < 0.0 || coords.x > 1.0 || coords.y < 0.0 || coords.y > 1.0) {
                    return vec4(0.0);
                }

                vec3 coords_tex = niri_geo_to_tex * vec3(coords, 1.0);
                vec4 color = texture2D(niri_tex, coords_tex.st);

                return color;
            }

            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                return crt_power_on(coords_geo, size_geo);
            }
          '';
        };

        window-close = {
          duration-ms = 250;
          curve = "ease-out-cubic";
          custom-shader = /* glsl */ ''
            vec4 crt_power_off(vec3 coords_geo, vec3 size_geo) {
                float p = niri_clamped_progress;

                float scale_x = mix(1.0, 0.0, pow(p, 3.0));
                float scale_y = mix(1.0, 0.005, min(1.0, p * 1.5));

                vec2 coords = coords_geo.xy - 0.5;
                coords.x /= scale_x;
                coords.y /= scale_y;
                coords += 0.5;

                if (coords.x < 0.0 || coords.x > 1.0 || coords.y < 0.0 || coords.y > 1.0) {
                    return vec4(0.0);
                }

                vec3 coords_tex = niri_geo_to_tex * vec3(coords, 1.0);
                vec4 color = texture2D(niri_tex, coords_tex.st);

                return color;
            }

            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                return crt_power_off(coords_geo, size_geo);
            }
          '';
        };
      };

      binds = {
        "Mod+O".toggle-overview = {};
        "Mod+Q".close-window = {};
        "Mod+Return".spawn = [terminal];
        "Mod+D".spawn = [launcher];
        "Mod+Shift+D".spawn-sh = finder;
        "Mod+Shift+Slash".show-hotkey-overlay = {};
        "Mod+Shift+E".quit = {};
        "Mod+X".spawn-sh = lock;

        # Focusing windows
        "Mod+Left".focus-column-left = {};
        "Mod+Down".focus-window-down = {};
        "Mod+Up".focus-window-up = {};
        "Mod+Right".focus-column-right = {};
        "Mod+H".focus-column-left = {};
        "Mod+J".focus-window-down = {};
        "Mod+K".focus-window-up = {};
        "Mod+L".focus-column-right = {};
        "Mod+WheelScrollRight" = { focus-column-right = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+WheelScrollLeft" = { focus-column-left = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+TouchpadScrollRight" = { focus-column-right = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+TouchpadScrollLeft" = { focus-column-left = {}; _props.cooldown-ms = scrollCoolDown; };

        # Moving windows
        "Mod+Shift+Left".move-column-left = {};
        "Mod+Shift+Down".move-window-down = {};
        "Mod+Shift+Up". move-window-up = {};
        "Mod+Shift+Right".move-column-right = {};
        "Mod+Shift+H".move-column-left = {};
        "Mod+Shift+J".move-window-down = {};
        "Mod+Shift+K".move-window-up = {};
        "Mod+Shift+L".move-column-right = {};
        "Mod+Shift+WheelScrollRight" = { move-column-right = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+Shift+WheelScrollLeft" = { move-column-left = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+Shift+TouchpadScrollRight" = { move-column-right = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+Shift+TouchpadScrollLeft" = { move-column-left = {}; _props.cooldown-ms = scrollCoolDown; };

        # Moving windows to extremeties
        "Mod+Home".focus-column-first = {};
        "Mod+End".focus-column-last = {};
        "Mod+Shift+Home".move-column-to-first = {};
        "Mod+Shift+End".move-column-to-last = {};

        # Focusing monitors
        "Mod+Ctrl+Left".focus-monitor-left = {};
        "Mod+Ctrl+Down".focus-monitor-down = {};
        "Mod+Ctrl+Up".focus-monitor-up = {};
        "Mod+Ctrl+Right".focus-monitor-right = {};
        "Mod+Ctrl+H".focus-monitor-left = {};
        "Mod+Ctrl+J".focus-monitor-down = {};
        "Mod+Ctrl+K".focus-monitor-up = {};
        "Mod+Ctrl+L".focus-monitor-right = {};

        # Moving windows to monitor
        "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = {};
        "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = {};
        "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = {};
        "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = {};
        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = {};
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = {};
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = {};
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = {};

        # Focusing workspaces
        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;
        "Mod+Page_Down".focus-workspace-down = {};
        "Mod+Page_Up".focus-workspace-up = {};
        "Mod+U".focus-workspace-down = {};
        "Mod+I".focus-workspace-up = {};
        "Mod+WheelScrollDown" = { focus-workspace-down = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+WheelScrollUp" = { focus-workspace-up = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+TouchpadScrollDown" = { focus-workspace-down = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+TouchpadScrollUp" = { focus-workspace-up = {}; _props.cooldown-ms = scrollCoolDown; };

        # Moving windows to workspaces
        "Mod+Shift+1".move-column-to-workspace = 1;
        "Mod+Shift+2".move-column-to-workspace = 2;
        "Mod+Shift+3".move-column-to-workspace = 3;
        "Mod+Shift+4".move-column-to-workspace = 4;
        "Mod+Shift+5".move-column-to-workspace = 5;
        "Mod+Shift+6".move-column-to-workspace = 6;
        "Mod+Shift+7".move-column-to-workspace = 7;
        "Mod+Shift+8".move-column-to-workspace = 8;
        "Mod+Shift+9".move-column-to-workspace = 9;
        "Mod+Shift+Page_Down".move-column-to-workspace-down = {};
        "Mod+Shift+Page_Up".move-column-to-workspace-up = {};
        "Mod+Shift+U".move-column-to-workspace-down = {};
        "Mod+Shift+I".move-column-to-workspace-up = {};
        "Mod+Shift+WheelScrollDown" = { move-column-to-workspace-down = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+Shift+WheelScrollUp" = { move-column-to-workspace-up = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+Shift+TouchpadScrollDown" = { move-column-to-workspace-down = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+Shift+TouchpadScrollUp" = { move-column-to-workspace-up = {}; _props.cooldown-ms = scrollCoolDown; };
        "Mod+Tab".focus-workspace-previous = {};

      # Column bindings
        "Mod+BracketLeft".consume-or-expel-window-left = {};
        "Mod+BracketRight".consume-or-expel-window-right = {};
        "Mod+Comma".consume-window-into-column = {};
        "Mod+Period".expel-window-from-column = {};

        "Mod+R".switch-preset-column-width = {};
        "Mod+Shift+R".switch-preset-window-height = {};
        "Mod+Ctrl+R".reset-window-height = {};
        "Mod+F".maximize-column = {};
        "Mod+Shift+F".fullscreen-window = {};

        "Mod+Ctrl+F".expand-column-to-available-width = {};

        "Mod+C".center-column = {};

        "Mod+Shift+C".center-visible-columns = {};

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";

        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+V".toggle-window-floating = {};
        "Mod+Shift+V".switch-focus-between-floating-and-tiling = {};

        "Mod+W".toggle-column-tabbed-display = {};

        # Brightness control
        "XF86MonBrightnessDown" = { spawn = [ mon-brightness-control "decrease" ]; _props.allow-when-locked = true; };
        "XF86MonBrightnessUp" = { spawn = [ mon-brightness-control "increase" ]; _props.allow-when-locked = true; };

        # Keyboard backlight control
        "XF86KbdBrightnessDown" = { spawn = [ kbd-brightness-control "decrease" ]; _props.allow-when-locked = true; };
        "XF86KbdBrightnessUp" = { spawn = [ kbd-brightness-control "increase" ]; _props.allow-when-locked = true; };

        # Volume control
        "XF86AudioMute" = { spawn = [ audio-volume-control "toggle" ]; _props.allow-when-locked = true; };
        "XF86AudioLowerVolume" = { spawn = [ audio-volume-control "decrease" ]; _props.allow-when-locked = true; };
        "XF86AudioRaiseVolume" = { spawn = [ audio-volume-control "increase" ]; _props.allow-when-locked = true; };

        # Media control
        "XF86AudioPlay" = { spawn =  [ playerctl "--player" "playerctld" "play-pause" ]; _props.allow-when-locked = true; };
        "XF86AudioNext" = { spawn =  [ playerctl "--player" "playerctld" "next" ]; _props.allow-when-locked = true; };
        "XF86AudioPrev" = { spawn =  [ playerctl "--player" "playerctld" "previous" ]; _props.allow-when-locked = true; };

        # Screenshot
        "Mod+P".screenshot = [ ];
        "Mod+Shift+XF86LaunchA".spawn-sh = "${grimshot} save output";
        "Mod+Ctrl+Shift+XF86LaunchA".spawn-sh = "${grimshot} copy output";

        # Screenshot selected area
        "Mod+Shift+XF86LaunchB".spawn-sh = "${grimshot} save area";
        "Mod+Ctrl+Shift+XF86LaunchB".spawn-sh = "${grimshot} copy area";

        # Screenshot specific window
        "Mod+Shift+XF86KbdBrightnessDown".spawn-sh = "${grimshot} save window";
        "Mod+Ctrl+Shift+XF86KbdBrightnessDown".spawn-sh = "${grimshot} copy window";
      };
    };
  };
}
