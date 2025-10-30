{ inputs, config, lib, pkgs, ... }:
{
  users.nixos.enable = true;

  nix-pille.wayland.windowManager.sway = {
    enable = true;
    terminal = "${config.programs.alacritty.package}/bin/alacritty";
  };

  nix-pille.programs = {
    alacritty.enable = true;  # Terminal emulator
    librewolf.enable = true;  # Web browser
    imv.enable = true;        # Image viewer
    zathura.enable = true;    # Document viewer
  };

  programs = {
    mpv.enable = true;        # Video player
  };

  nix-pille.fonts.enable = true;
  nix-pille.gtk.enable = true;

  home.stateVersion = "24.11";

  # Enable dconf as many programs read dconf data
  dconf.enable = true;

  nix-pille.monitors = [
    { # Built in display
      name = "*";
      width = 1920;
      height = 1080;
      refreshRate = 59.990;
      x = 0;
      y = 0;
      scale = 1.0;
      primary = true;
    }
  ];
}
