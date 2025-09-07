{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.users.nixos;
in
{
  options.users.nixos.enable = mkEnableOption "Common options for nixos";


  config = mkIf cfg.enable {
    # Enable commonly used CLI tools
    nix-pille.cli.enable = true;

    home = {
      username = "nixos";
      homeDirectory = "/home/${config.home.username}";
    };

    # Enable XDG base directories management
    xdg.enable = true;
    nix.enable = true;

    # Enable home-manager
    programs.home-manager.enable = true;
    news.display = "show";

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";
  };
}
