{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    ./hardware.nix
    ./disk-config.nix
  ];

  # Add flakes to nix registry (used in legacy commands)
  nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # Boot settings
  boot.enable = true;

  # Networking settings
  networking.enable = true;
  networking.hostName = "graaboellet";

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
  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  # Enable virtualisation technologies
  virtualisation.enable = true;

  # Large font for HiDPI display
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-132n.psf.gz";

  # Install version
  system.stateVersion = "26.05";
}

