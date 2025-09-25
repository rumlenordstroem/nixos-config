{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    # Hardware
    ./hardware.nix
  ];

  # Add flakes to nix registry (used in legacy commands)
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # Boot settings
  boot.enable = true;

  # Networking settings settings
  networking.enable = true;
  networking.hostName = "p43s";

  # SSH
  services.openssh.enable = true;

  # Time zone and locale.
  services.automatic-timezoned.enable = true;
  i18n.enable = true;

  # User
  users.rumle.enable = true;

  # Configure keymap
  console.keyMap = "dk-latin1";
  services.xserver.xkb = {
    layout = "dk";
    options = "grp:win_space_toggle";
  };

  # Packages
  programs = {
    git.enable = true;
  };
  environment.systemPackages = with pkgs; [
    wget
  ];

  # Enable virtualisation technologies
  virtualisation.enable = true;

  # Fonts
  fonts.enableDefaultPackages = true;

  # Make system prepared for a wayland compositor
  wayland-session.enable = true;

  # Enable display manager
  tuigreet.enable = true;

  # Enable pipewire audio
  pipewire.enable = true;

  # Install version
  system.stateVersion = "24.11";
}

