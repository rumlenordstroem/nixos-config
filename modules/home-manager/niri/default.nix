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
    # nix-pille.icons = {
    #   enable = true;
    #   package = pkgs.papirus-icon-theme.overrideAttrs (oldAttrs: {
    #     patchPhase = /* sh */ ''
    #       find . -type f -name "*.svg" -exec sed -i 's/#${if config.colorScheme.variant == "dark" then "dfdfdf" else "444444"}/#${config.colorScheme.palette.base05}/g' {} +
    #     '';
    #     dontPatchELF = true;
    #     dontPatchShebangs = true;
    #     dontRewriteSymlinks = true;
    #   });
    #   name = if config.colorScheme.variant == "dark" then "Papirus-Dark" else "Papirus-Light";
    # };

    # System cursor theme
    home.pointerCursor = {
      # package = pkgs.capitaine-cursors;
      name = if config.colorScheme.variant == "dark" then "capitaine-cursors-white" else "capitaine-cursors";
      size = 32;
      gtk.enable = true;
    };

    services.swww.enable = true;

    # Niri config
    programs.niri.enable = true;
    programs.niri.settings =

    with config.lib.niri.actions;

    let
      # Essentials
      swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
      swaylock = "${config.programs.swaylock.package}/bin/swaylock";
      swww = "${config.services.swww.package}/bin/swww";
      cut = "${pkgs.coreutils}/bin/cut";
      terminal = "${config.programs.alacritty.package}/bin/alacritty";
      launcher = "${config.programs.fuzzel.package}/bin/fuzzel";
      finder = "${pkgs.fd}/bin/fd --type file|${launcher} --dmenu|${pkgs.findutils}/bin/xargs -I {} ${pkgs.xdg-utils}/bin/xdg-open '{}'";
      playerctl = "${config.services.playerctld.package}/bin/playerctl";
      grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";
      kbd-brightness-control = "${pkgs.kbd-brightness-control}/bin/kbd-brightness-control";
      audio-volume-control = "${pkgs.audio-volume-control}/bin/audio-volume-control";
      mon-brightness-control = "${pkgs.mon-brightness-control}/bin/mon-brightness-control";

      fallback = "${config.colorScheme.palette.base02}"; # Fallback color for wallpaper

      scrollCoolDown = 200;

    in {
      input.keyboard = {
        xkb = {
          layout = "us(mac),dk(mac),kr";
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
        tap = false;
        dwt = false;
        natural-scroll = true;
        click-method = "clickfinger";
      };

      outputs = builtins.listToAttrs(map(monitor: {
        name = monitor.name;
        value = {
          mode = {
            width = monitor.width;
            height = monitor.height;
            refresh = monitor.refreshRate;
          };
          scale = monitor.scale;
          position = {
            x = monitor.x;
            y = monitor.y;
          };
        };
      }) (config.nix-pille.monitors));

      # No client side decorations
      prefer-no-csd = true;

      # Cursor settings
      cursor = {
        size = config.home.pointerCursor.size;
        theme = config.home.pointerCursor.name;
      };

      environment = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
      };

      layout = {
        gaps = 6;
        border = with config.colorScheme.palette; {
          enable = true;
          width = 2;
          active.color = "#${base07}";
          inactive.color = "#${base04}";
        };

        struts = {
          left = 0;
          right = 0;
          top = 0;
          bottom = 0;
        };

        focus-ring.enable = false;

        tab-indicator = with config.colorScheme.palette; {
          active.color = "#${base0E}";
          inactive.color = "#${base07}";
          urgent.color = "#${base08}";
          width = 2;
          gap = -2;
          length.total-proportion = 1.0;
        };

        background-color = "transparent";
      };

      window-rules = [
        {
          geometry-corner-radius = {
            top-left = 8.0;
            top-right = 8.0;
            bottom-left = 8.0;
            bottom-right = 8.0;
          };
          clip-to-geometry = true;
        }
      ];

      layer-rules = [
        {
          matches = [
            { namespace = "^swww-daemon$"; }
          ];
          place-within-backdrop = true;
        }
      ];

      animations = {
        workspace-switch = {
          kind.spring = {
            damping-ratio = 1.0;
            stiffness = 500;
            epsilon = 0.0001;
          };
        };

        window-open = {
          kind.easing = {
            duration-ms = 500;
            curve = "ease-out-quad";
          };
          custom-shader = /* glsl */ ''
            float random(vec2 st) {
                return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
            }

            vec4 glitch_slide(vec3 coords_geo, vec3 size_geo) {
                float p = niri_clamped_progress;
                float intensity = (1.0 - p);
                float noise = random(vec2(0.0, coords_geo.y * 50.0 + p));
                float shift = (noise - 0.5) * 0.1 * intensity;

                vec2 r_offset = vec2(shift + 0.02 * intensity, 0.0);
                vec2 g_offset = vec2(shift, 0.0);
                vec2 b_offset = vec2(shift - 0.02 * intensity, 0.0);

                vec3 r_geo = vec3(coords_geo.xy + r_offset, 1.0);
                vec3 g_geo = vec3(coords_geo.xy + g_offset, 1.0);
                vec3 b_geo = vec3(coords_geo.xy + b_offset, 1.0);

                float r = texture2D(niri_tex, (niri_geo_to_tex * r_geo).st).r;
                float g = texture2D(niri_tex, (niri_geo_to_tex * g_geo).st).g;
                float b = texture2D(niri_tex, (niri_geo_to_tex * b_geo).st).b;
                float a = texture2D(niri_tex, (niri_geo_to_tex * g_geo).st).a;

                if (coords_geo.y > p * 1.2) a = 0.0;

                return vec4(r, g, b, a * p); 
            }

            vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                // Du kan ændre den her til crt_power_on hvis du vil prøve den anden
                return glitch_slide(coords_geo, size_geo);
            }
             '';
        };

        window-close = {
          kind.easing = {
            duration-ms = 500;
            curve = "ease-out-cubic";
          };
          custom-shader = /* glsl */ ''
            float random(vec2 st) {
                return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
            }

            vec4 glitch_slide(vec3 coords_geo, vec3 size_geo) {
                float p = niri_clamped_progress;
                float intensity = (1.0 - p);
                float noise = random(vec2(0.0, coords_geo.y * 50.0 + p));
                float shift = (noise - 0.5) * 0.1 * intensity;

                vec2 r_offset = vec2(shift + 0.02 * intensity, 0.0);
                vec2 g_offset = vec2(shift, 0.0);
                vec2 b_offset = vec2(shift - 0.02 * intensity, 0.0);

                vec3 r_geo = vec3(coords_geo.xy + r_offset, 1.0);
                vec3 g_geo = vec3(coords_geo.xy + g_offset, 1.0);
                vec3 b_geo = vec3(coords_geo.xy + b_offset, 1.0);

                float r = texture2D(niri_tex, (niri_geo_to_tex * r_geo).st).r;
                float g = texture2D(niri_tex, (niri_geo_to_tex * g_geo).st).g;
                float b = texture2D(niri_tex, (niri_geo_to_tex * b_geo).st).b;
                float a = texture2D(niri_tex, (niri_geo_to_tex * g_geo).st).a;

                if (coords_geo.y > p * 1.2) a = 0.0;

                return vec4(r, g, b, a * intensity); 
            }

            vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                return glitch_slide(coords_geo, size_geo);
            }
             '';
        };
      };

      binds = {
        "Mod+O".action = toggle-overview;
        "Mod+Q".action = close-window;
        "Mod+Return".action.spawn = terminal;
        "Mod+D".action.spawn = launcher;
        "Mod+Shift+D".action.spawn-sh = finder;
        "Mod+Shift+Slash".action = show-hotkey-overlay;
        "Mod+Shift+E".action = quit;
        "Mod+X".action.spawn-sh = "${swaylock} --image $(${swww} query | ${cut} --delimiter ' ' --fields 9)";

        # Focusing windows
        "Mod+Left".action = focus-column-left;
        "Mod+Down".action = focus-window-down;
        "Mod+Up".action = focus-window-up;
        "Mod+Right".action = focus-column-right;
        "Mod+H".action = focus-column-left;
        "Mod+J".action = focus-window-down;
        "Mod+K".action = focus-window-up;
        "Mod+L".action = focus-column-right;
        "Mod+WheelScrollRight" = { action = focus-column-right; cooldown-ms = scrollCoolDown; };
        "Mod+WheelScrollLeft" = { action = focus-column-left; cooldown-ms = scrollCoolDown; };
        "Mod+TouchpadScrollRight" = { action = focus-column-right; cooldown-ms = scrollCoolDown; };
        "Mod+TouchpadScrollLeft" = { action = focus-column-left; cooldown-ms = scrollCoolDown; };

        # Moving windows
        "Mod+Shift+Left".action = move-column-left;
        "Mod+Shift+Down".action = move-window-down;
        "Mod+Shift+Up".action =  move-window-up;
        "Mod+Shift+Right".action = move-column-right;
        "Mod+Shift+H".action = move-column-left;
        "Mod+Shift+J".action = move-window-down;
        "Mod+Shift+K".action = move-window-up;
        "Mod+Shift+L".action = move-column-right;
        "Mod+Shift+WheelScrollRight" = { action = move-column-right; cooldown-ms = scrollCoolDown; };
        "Mod+Shift+WheelScrollLeft" = { action = move-column-left; cooldown-ms = scrollCoolDown; };
        "Mod+Shift+TouchpadScrollRight" = { action = move-column-right; cooldown-ms = scrollCoolDown; };
        "Mod+Shift+TouchpadScrollLeft" = { action = move-column-left; cooldown-ms = scrollCoolDown; };

        # Moving windows to extremeties
        "Mod+Home".action = focus-column-first;
        "Mod+End".action = focus-column-last;
        "Mod+Shift+Home".action = move-column-to-first;
        "Mod+Shift+End".action = move-column-to-last;

        # Focusing monitors
        "Mod+Ctrl+Left".action = focus-monitor-left;
        "Mod+Ctrl+Down".action = focus-monitor-down;
        "Mod+Ctrl+Up".action = focus-monitor-up;
        "Mod+Ctrl+Right".action = focus-monitor-right;
        "Mod+Ctrl+H".action = focus-monitor-left;
        "Mod+Ctrl+J".action = focus-monitor-down;
        "Mod+Ctrl+K".action = focus-monitor-up;
        "Mod+Ctrl+L".action = focus-monitor-right;

        # Moving windows to monitor
        "Mod+Shift+Ctrl+Left".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+Down".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+Up".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+Right".action = move-column-to-monitor-right;
        "Mod+Shift+Ctrl+H".action = move-column-to-monitor-left;
        "Mod+Shift+Ctrl+J".action = move-column-to-monitor-down;
        "Mod+Shift+Ctrl+K".action = move-column-to-monitor-up;
        "Mod+Shift+Ctrl+L".action = move-column-to-monitor-right;

        # Focusing workspaces
        "Mod+1".action.focus-workspace = 1;
        "Mod+2".action.focus-workspace = 2;
        "Mod+3".action.focus-workspace = 3;
        "Mod+4".action.focus-workspace = 4;
        "Mod+5".action.focus-workspace = 5;
        "Mod+6".action.focus-workspace = 6;
        "Mod+7".action.focus-workspace = 7;
        "Mod+8".action.focus-workspace = 8;
        "Mod+9".action.focus-workspace = 9;
        "Mod+Page_Down".action = focus-workspace-down;
        "Mod+Page_Up".action = focus-workspace-up;
        "Mod+U".action = focus-workspace-down;
        "Mod+I".action = focus-workspace-up;
        "Mod+WheelScrollDown" = { action = focus-workspace-down; cooldown-ms = scrollCoolDown; };
        "Mod+WheelScrollUp" = { action = focus-workspace-up; cooldown-ms = scrollCoolDown; };
        "Mod+TouchpadScrollDown" = { action = focus-workspace-down; cooldown-ms = scrollCoolDown; };
        "Mod+TouchpadScrollUp" = { action = focus-workspace-up; cooldown-ms = scrollCoolDown; };

        # Moving windows to workspaces
        "Mod+Shift+1".action.move-column-to-workspace = 1;
        "Mod+Shift+2".action.move-column-to-workspace = 2;
        "Mod+Shift+3".action.move-column-to-workspace = 3;
        "Mod+Shift+4".action.move-column-to-workspace = 4;
        "Mod+Shift+5".action.move-column-to-workspace = 5;
        "Mod+Shift+6".action.move-column-to-workspace = 6;
        "Mod+Shift+7".action.move-column-to-workspace = 7;
        "Mod+Shift+8".action.move-column-to-workspace = 8;
        "Mod+Shift+9".action.move-column-to-workspace = 9;
        "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
        "Mod+Shift+Page_Up".action = move-column-to-workspace-up;
        "Mod+Shift+U".action = move-column-to-workspace-down;
        "Mod+Shift+I".action = move-column-to-workspace-up;
        "Mod+Shift+WheelScrollDown" = { action = move-column-to-workspace-down; cooldown-ms = scrollCoolDown; };
        "Mod+Shift+WheelScrollUp" = { action = move-column-to-workspace-up; cooldown-ms = scrollCoolDown; };
        "Mod+Shift+TouchpadScrollDown" = { action = move-column-to-workspace-down; cooldown-ms = scrollCoolDown; };
        "Mod+Shift+TouchpadScrollUp" = { action = move-column-to-workspace-up; cooldown-ms = scrollCoolDown; };
        "Mod+Tab".action = focus-workspace-previous;

        # Column bindings
        "Mod+BracketLeft".action = consume-or-expel-window-left;
        "Mod+BracketRight".action = consume-or-expel-window-right;
        "Mod+Comma".action = consume-window-into-column;
        "Mod+Period".action = expel-window-from-column;

        "Mod+R".action = switch-preset-column-width;
        "Mod+Shift+R".action = switch-preset-window-height;
        "Mod+Ctrl+R".action = reset-window-height;
        "Mod+F".action = maximize-column;
        "Mod+Shift+F".action = fullscreen-window;

        "Mod+Ctrl+F".action = expand-column-to-available-width;

        "Mod+C".action = center-column;

        "Mod+Shift+C".action = center-visible-columns;

        "Mod+Minus".action = set-column-width "-10%";
        "Mod+Equal".action = set-column-width "+10%";

        "Mod+Shift+Minus".action = set-window-height "-10%";
        "Mod+Shift+Equal".action = set-window-height "+10%";

        "Mod+V".action = toggle-window-floating;
        "Mod+Shift+V".action = switch-focus-between-floating-and-tiling;

        "Mod+W".action = toggle-column-tabbed-display;

        # Brightness control
        "XF86MonBrightnessDown" = { action.spawn = [ mon-brightness-control "decrease" ]; allow-when-locked = true; };
        "XF86MonBrightnessUp" = { action.spawn = [ mon-brightness-control "increase" ]; allow-when-locked = true; };

        # Keyboard backlight control
        "XF86KbdBrightnessDown" = { action.spawn = [ kbd-brightness-control "decrease" ]; allow-when-locked = true; };
        "XF86KbdBrightnessUp" = { action.spawn = [ kbd-brightness-control "increase" ]; allow-when-locked = true; };

        # Volume control
        "XF86AudioMute" = { action.spawn = [ audio-volume-control "toggle" ]; allow-when-locked = true; };
        "XF86AudioLowerVolume" = { action.spawn = [ audio-volume-control "decrease" ]; allow-when-locked = true; };
        "XF86AudioRaiseVolume" = { action.spawn = [ audio-volume-control "increase" ]; allow-when-locked = true; };

        # Media control
        "XF86AudioPlay" = { action.spawn =  [ playerctl "--player" "playerctld" "play-pause" ]; allow-when-locked = true; };
        "XF86AudioNext" = { action.spawn =  [ playerctl "--player" "playerctld" "next" ]; allow-when-locked = true; };
        "XF86AudioPrev" = { action.spawn =  [ playerctl "--player" "playerctld" "previous" ]; allow-when-locked = true; };

        # Screenshot
        "Mod+P".action.screenshot = [ ];
        "Mod+Shift+XF86LaunchA".action.spawn-sh = "${grimshot} save output";
        "Mod+Ctrl+Shift+XF86LaunchA".action.spawn-sh = "${grimshot} copy output";

        # Screenshot selected area
        "Mod+Shift+XF86LaunchB".action.spawn-sh = "${grimshot} save area";
        "Mod+Ctrl+Shift+XF86LaunchB".action.spawn-sh = "${grimshot} copy area";

        # Screenshot specific window
        "Mod+Shift+XF86KbdBrightnessDown".action.spawn-sh = "${grimshot} save window";
        "Mod+Ctrl+Shift+XF86KbdBrightnessDown".action.spawn-sh = "${grimshot} copy window";
      };
    };
  };
}
