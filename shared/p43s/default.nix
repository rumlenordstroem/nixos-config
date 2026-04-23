{ inputs, config, lib, pkgs, ... }:
{
  # Global color scheme. See https://github.com/tinted-theming/base16-schemes
  stylix.enable = true;
  stylix.autoEnable = false;
  # stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-latte.yaml";

  # Temporary hardcoded theme
  # https://github.com/tinted-theming/schemes/pull/95
  stylix.base16Scheme = {
    system = "base16";
    name = "Catppuccin Frappe";
    author = "https://github.com/catppuccin/catppuccin";
    variant = "light";
    palette = {
      base00 = "eff1f5"; # base
      base01 = "e6e9ef"; # mantle
      base02 = "ccd0da"; # surface0
      base03 = "bcc0cc"; # surface1
      base04 = "acb0be"; # surface2
      base05 = "4c4f69"; # text
      base06 = "dc8a78"; # rosewater
      base07 = "7287fd"; # lavender
      base08 = "d20f39"; # red
      base09 = "fe640b"; # peach
      base0A = "df8e1d"; # yellow
      base0B = "40a02b"; # green
      base0C = "179299"; # teal
      base0D = "1e66f5"; # blue
      base0E = "8839ef"; # mauve
      base0F = "dd7878"; # flamingo
    };
  };

  # Enable XDG base directories management
  nix.settings.use-xdg-base-directories = true;
}
