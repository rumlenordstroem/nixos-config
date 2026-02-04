{ inputs, config, lib, pkgs, ... }:
{
  users.rumle.enable = true;

  nix-pille.programs = {
    niri.enable = true;       # Window manager
    alacritty.enable = true;  # Terminal emulator
    librewolf.enable = true;  # Web browser
    imv.enable = true;        # Image viewer
    zathura.enable = true;    # Document viewer
    keepassxc.enable = true;  # Password manager
  };

  programs = {
    vscode.enable = true;     # Code editor
    mpv.enable = true;        # Video player
  };

  nix-pille.fonts.enable = true;
  nix-pille.gtk.enable = true;

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
      kicad              # Electronics design tool
    ];

    stateVersion = "23.11";
  };

  # Enable dconf as many programs read dconf data
  dconf.enable = true;

  services.syncthing = {
    enable = true;
    settings = {
      folders = {
        dcim = {
          id = "dcim";
          path = "~/DCIM";
          devices = [ "pixel" ];
        };
        pictures = {
          id = "pictures";
          path = "~/Pictures";
          devices = [ "pixel" ];
        };
        public = {
          id = "public";
          path = "~/Public";
          devices = [ "pixel" ];
        };
        music = {
          id = "music";
          path = "~/Music";
          devices = [ "pixel" ];
        };
      };
    };
  };

  nix-pille.monitors = [
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
