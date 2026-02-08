{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    # Hardware
    ./hardware.nix

    # Create an ISO image
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  # Enable nix helper
  programs.nh.enable = true;

  # Add flakes to nix registry (used in legacy commands)
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # Networking settings settings
  # networking.enable = true;
  networking.hostName = "iso";

  # SSH
  services.openssh.enable = true;

  # Time zone and locale.
  # services.automatic-timezoned.enable = true;
  time.timeZone = "Europe/Copenhagen";
  i18n.enable = true;

  # User
  users.nixos.enable = true;

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

  # Make system prepared for a wayland compositor
  wayland-session.enable = true;

  # Enable display manager
  tuigreet.enable = true;

  # Fonts
  fonts.enableDefaultPackages = true;

  # Enable pipewire audio
  pipewire.enable = true;
}

