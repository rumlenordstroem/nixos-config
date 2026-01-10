{ inputs, config, lib, pkgs, ... }:
{
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  # Global color scheme. See https://github.com/tinted-theming/base16-schemes
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-frappe;

  # Enable XDG base directories management
  nix.settings.use-xdg-base-directories = true;
}
