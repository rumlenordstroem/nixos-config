{ inputs, config, lib, pkgs, ... }:
{
  users.rumle.enable = true;
  
  nix-pille.wayland.windowManager.sway = {
    enable = true;
    wallpaper = "~/Pictures/Wallpapers/brut.PNG";
    terminal = "${config.programs.alacritty.package}/bin/alacritty";
  };
  wayland.windowManager.sway.config.input."type:keyboard".xkb_layout = "dk";

  nix-pille.programs = {
    alacritty.enable = true;  # Terminal emulator
    librewolf.enable = true;  # Web browser
    imv.enable = true;        # Image viewer
    zathura.enable = true;    # Document viewer
    keepassxc.enable = true;  # Password manager
  };

  programs = {
    mpv.enable = true;        # Video player
    vscode.enable = true;     # GUI text editor
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
      kicad              # PCB design suite
      digikam            # Photo management tool
    ];

    stateVersion = "24.11";
  };

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
      };
    };
  };

  # Enable dconf as many programs read dconf data
  dconf.enable = true;

  nix-pille.monitors = [
    { # Built in display
      name = "eDP-1";
      width = 1920;
      height = 1080;
        refreshRate = 60.001;
      x = 0;
      y = 0;
      scale = 1.0;
      primary = true;
    }
  ];
}
