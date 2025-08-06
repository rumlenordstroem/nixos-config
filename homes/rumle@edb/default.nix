{ inputs, config, lib, pkgs, ... }:
{
  users.rumle.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    config.terminal = "${config.programs.alacritty.package}/bin/alacritty";
    wallpaper = "~/Pictures/wallpapers/the-glow-transparent.png";
    config.input."type:keyboard".xkb_layout = "us(mac),dk(mac),kr";
  };

  programs = {
    alacritty.enable = true;  # Terminal emulator
    librewolf.enable = true;  # Web browser
    imv.enable = true;        # Image viewer
    mpv.enable = true;        # Video player
    vscode.enable = true;     # GUI text editor
    zathura.enable = true;    # Document viewer
    keepassxc.enable = true;  # Password manager
  };

  fonts.fontconfig.enable = true;
  gtk.enable = true;

  home = {
    # User packages
    packages = with pkgs; [
      # Graphical programs
      qbittorrent        # Torrent client
      libreoffice        # Office suite
      signal-desktop     # Message application
      element-desktop    # Matrix client
      tutanota-desktop   # Email client
      inkscape           # Vector graphics editor
      freecad-wayland    # 3D modeling tool
    ];

    stateVersion = "23.11";
  };

  # Enable dconf as many programs read dconf data
  dconf.enable = true;

  monitors = [
    { # Built in display
      name = "eDP-1";
      width = 2880;
      height = 1800;
      refreshRate = 59.990;
      x = 0;
      y = 1440;
      scale = 2.0;
      primary = true;
    }
    { # External monitor
      name = "HDMI-A-3";
      width = 2560;
      height = 1440;
      refreshRate = 59.972;
      x = 0;
      y = 0;
      scale = 1.0;
    }
  ];
}
