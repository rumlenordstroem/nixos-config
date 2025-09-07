{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.wayland.windowManager.sway;
in
{
  options.nix-pille.wayland.windowManager.sway = {
    enable = mkEnableOption {
      name = "nix pille sway configuration";
    };
    # This option cannot be defined under sway.config
    # due to how the sway module is implemented.
    # TODO: define a generic wallpaper module or
    # use something like stylix in the future
    wallpaper = mkOption {
        type = types.str;
        default = toString pkgs.nixos-artwork.wallpapers.simple-light-gray.gnomeFilePath;
        description = "Wallpaper for Sway compositor";
    };

    terminal = mkOption {
        type = types.str;
        default = "${pkgs.alacritty}/bin/alacritty";
        description = "Terminal for Sway compositor";
    };
  };

  config = mkIf cfg.enable {
    nix-pille.programs = {
      fuzzel.enable = true;        # Menu
      swaylock.enable = true;      # Screen locker (systemd service)
      yambar.enable = true;        # Status bar (systemd service)
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
          find . -type f -name "*.svg" -exec sed -i 's/#${if config.colorScheme.variant == "dark" then "dfdfdf" else "444444"}/#${config.colorScheme.palette.base05}/g' {} +
        '';
        dontPatchELF = true;
        dontPatchShebangs = true;
        dontRewriteSymlinks = true;
      });
      name = if config.colorScheme.variant == "dark" then "Papirus-Dark" else "Papirus-Light";
    };

    # System cursor theme
    home.pointerCursor = {
      package = pkgs.capitaine-cursors;
      name = if config.colorScheme.variant == "dark" then "capitaine-cursors-white" else "capitaine-cursors";
      size = 32;
      gtk.enable = true;
    };

    # Sway config
    wayland.windowManager.sway = 
    let
      # Essentials
      swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
      swaylock = "${config.programs.swaylock.package}/bin/swaylock";
      menu = "${config.programs.fuzzel.package}/bin/fuzzel";
      finder = "${pkgs.fd}/bin/fd --type file|${menu} --dmenu|${pkgs.findutils}/bin/xargs -I {} ${pkgs.xdg-utils}/bin/xdg-open '{}'";
      playerctl = "${config.services.playerctld.package}/bin/playerctl";
      grimshot = "${pkgs.sway-contrib.grimshot}/bin/grimshot";

      fallback = "${config.colorScheme.palette.base02}"; # Fallback color for wallpaper

      # Basic bindings
      modifier = "Mod4";
      left = "h";
      down = "j";
      up = "k";
      right = "l";

    in {
      enable = true;

      xwayland = false;
      checkConfig = false;
      config = {
        fonts = { names = [ "monospace" ]; size = 10.0; }; # TODO

        input = {
          # Keyboard layout
          "type:keyboard" = {
            xkb_options = "grp:alt_caps_toggle";
          };
          # Touchpad
          "type:touchpad" = {
            accel_profile = "adaptive";
            pointer_accel = "0.20";
            natural_scroll = "enabled";
            scroll_factor = "0.35";
            dwt = "disabled";
            click_method = "clickfinger";
          };
          # Mouse
          "type:pointer" = {
            accel_profile = "flat";
            pointer_accel = "-0.35";
          };
        };

        output = builtins.listToAttrs(map(monitor: {
          name = monitor.name;
          value = {
            mode = "${toString monitor.width}x${toString monitor.height}@${toString monitor.refreshRate}Hz";
            scale = toString monitor.scale;
            pos = "${toString monitor.x} ${toString monitor.y}";
          };
        }) (config.nix-pille.monitors)) // { "*".background = "${cfg.wallpaper} fill '#${fallback}'"; };

        startup = [ ];

        gaps = {
          inner = 6;
          outer = 0;
          smartGaps = false;
          smartBorders = "off";
        };

        window = {
          titlebar = false;
          hideEdgeBorders = "none";
          border = 2;
        };

        # Hides default swaybar
        bars = [ ];

        keybindings = {
          # Essentials
          "${modifier}+Return" = "exec ${cfg.terminal}";
          "${modifier}+q" = "kill";
          "${modifier}+d" = "exec ${menu}";
          "${modifier}+Shift+d" = "exec ${finder}";

          # Window focus
          "${modifier}+${left}" = "focus left";
          "${modifier}+${down}" = "focus down";
          "${modifier}+${up}" = "focus up";
          "${modifier}+${right}" = "focus right";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";

          # Window movement
          "${modifier}+Shift+${left}" = "move left";
          "${modifier}+Shift+${down}" = "move down";
          "${modifier}+Shift+${up}" = "move up";
          "${modifier}+Shift+${right}" = "move right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # Window layout
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+v" = "splitt";
          "${modifier}+w" = "layout toggle tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+space" = "focus mode_toggle";

          # Workspace switching
          "${modifier}+1" = "workspace number 1";
          "${modifier}+2" = "workspace number 2";
          "${modifier}+3" = "workspace number 3";
          "${modifier}+4" = "workspace number 4";
          "${modifier}+5" = "workspace number 5";
          "${modifier}+6" = "workspace number 6";
          "${modifier}+7" = "workspace number 7";
          "${modifier}+8" = "workspace number 8";
          "${modifier}+9" = "workspace number 9";

          # Move windows
          "${modifier}+Shift+1" = "move container to workspace number 1; workspace 1";
          "${modifier}+Shift+2" = "move container to workspace number 2; workspace 2";
          "${modifier}+Shift+3" = "move container to workspace number 3; workspace 3";
          "${modifier}+Shift+4" = "move container to workspace number 4; workspace 4";
          "${modifier}+Shift+5" = "move container to workspace number 5; workspace 5";
          "${modifier}+Shift+6" = "move container to workspace number 6; workspace 6";
          "${modifier}+Shift+7" = "move container to workspace number 7; workspace 7";
          "${modifier}+Shift+8" = "move container to workspace number 8; workspace 8";
          "${modifier}+Shift+9" = "move container to workspace number 9; workspace 9";

          # Scratchpad
          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";

          "${modifier}+x" = "exec ${swaylock}";
          "${modifier}+c" = "reload";
          "${modifier}+Shift+e" = "exec ${pkgs.systemd}/bin/systemctl --user stop sway-session.target | ${swaymsg} exit";

          "${modifier}+r" = "mode resize";

          # Brightness control
          "--locked XF86MonBrightnessDown" = "exec ${pkgs.mon-brightness-control}/bin/mon-brightness-control decrease";
          "--locked XF86MonBrightnessUp" = "exec ${pkgs.mon-brightness-control}/bin/mon-brightness-control increase";

          # Keyboard backlight control
          "--locked XF86KbdBrightnessDown" = "exec ${pkgs.kbd-brightness-control}/bin/kbd-brightness-control decrease";
          "--locked XF86KbdBrightnessUp" = "exec ${pkgs.kbd-brightness-control}/bin/kbd-brightness-control increase";

          # Volume control
          "--locked XF86AudioMute" = "exec ${pkgs.audio-volume-control}/bin/audio-volume-control toggle";
          "--locked XF86AudioLowerVolume" = "exec ${pkgs.audio-volume-control}/bin/audio-volume-control decrease";
          "--locked XF86AudioRaiseVolume" = "exec ${pkgs.audio-volume-control}/bin/audio-volume-control increase";

          # Media control
          "--locked XF86AudioPlay" = "exec ${playerctl} --player playerctld play-pause";
          "--locked XF86AudioNext" = "exec ${playerctl} --player playerctld next";
          "--locked XF86AudioPrev" = "exec ${playerctl} --player playerctld previous";

          # Screenshot
          "${modifier}+Shift+XF86LaunchA" = "exec ${grimshot} save output";
          "${modifier}+Ctrl+Shift+XF86LaunchA" = "exec ${grimshot} copy output";

          # Screenshot selected area
          "${modifier}+Shift+XF86LaunchB" = "exec ${grimshot} save area";
          "${modifier}+Ctrl+Shift+XF86LaunchB" = "exec ${grimshot} copy area";

          # Screenshot specific window
          "${modifier}+Shift+XF86KbdBrightnessDown" = "exec ${grimshot} save window";
          "${modifier}+Ctrl+Shift+XF86KbdBrightnessDown" = "exec ${grimshot} copy window";
        };

        floating = {
          # For window manipulation with pointer
          inherit modifier;

          # Make some windows float by default
          criteria = [
            { title = "(?:Open|Save) (?:File|Folder|As)"; }
            { app_id = "localsend_app"; }
            { app_id = "org.keepassxc.KeePassXC"; }
          ];
        };

        modes = {
          resize = {
            "${left}" = "resize shrink width 10px";
            "${down}" = "resize grow height 10px";
            "${up}" = "resize shrink height 10px";
            "${right}" = "resize grow width 10px";

            "Left" = "resize shrink width 10px";
            "Down" = "resize grow height 10px";
            "Up" = "resize shrink height 10px";
            "Right" = "resize grow width 10px";

            # Return to default mode
            "Return" = "mode default";
            "Escape" = "mode default";
          };
        };

        # Cursor theme
        seat.seat0.xcursor_theme = "${config.home.pointerCursor.name} ${toString config.home.pointerCursor.size}";

        # Colors
        colors = with config.colorScheme.palette; {
          focused = {
            border = "#${base07}";
            background = "#${base00}";
            text = "#${base05}";
            indicator = "#${base06}";
            childBorder = "#${base04}";
          };

          focusedInactive = {
            border = "#${base04}";
            background = "#${base00}";
            text = "#${base05}";
            indicator = "#${base04}";
            childBorder = "#${base01}";
          };

          unfocused = {
            border = "#${base04}";
            background = "#${base00}";
            text = "#${base05}";
            indicator = "#${base04}";
            childBorder = "#${base01}";
          };
        };
      };

      extraSessionCommands = /*shell*/ ''
        # Make electron apps work on wayland
        export NIXOS_OZONE_WL=1
        export ELECTRON_OZONE_PLATFORM_HINT=auto
      '';

      extraConfig = ''
        # Allow switching between workspaces with left and right swipes
        bindgesture swipe:4:right workspace prev
        bindgesture swipe:4:left workspace next
        bindswitch --reload --locked lid:on exec ${swaylock}
      '';
    };
  };
}
