{ inputs, config, lib, pkgs, ... }:
{
  # Global color scheme. See https://github.com/tinted-theming/base16-schemes
  stylix.enable = true;
  stylix.autoEnable = false;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-frappe.yaml";

  # Enable XDG base directories management
  nix.settings.use-xdg-base-directories = true;
}
