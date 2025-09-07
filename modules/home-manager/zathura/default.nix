{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.zathura;
in
{
  options.nix-pille.programs.zathura = {
    enable = mkEnableOption {
      name = "nix pille zathura configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.zathura = {
      enable = true;

      options = with config.colorScheme.palette; {
        # Settings
        selection-clipboard = "clipboard";
        recolor = true;
        page-padding = 5;
        statusbar-v-padding = 4;
        statusbar-h-padding = 20;
        statusbar-basename = true;
        font = "monospace normal 10";

        # Color
        default-fg = "#${base05}";
        default-bg = "#${base00}";
        completion-bg = "#${base02}";
        completion-fg = "#${base05}";
        completion-highlight-bg = "#${base02}";
        completion-highlight-fg = "#${base05}";
        completion-group-bg = "#${base02}";
        completion-group-fg = "#${base0D}";
        statusbar-fg = "#${base04}";
        statusbar-bg = "#${base01}";
        notification-bg = "#${base02}";
        notification-fg = "#${base05}";
        notification-error-bg = "#${base02}";
        notification-error-fg = "#${base08}";
        notification-warning-bg = "#${base02}";
        notification-warning-fg = "#${base0A}";
        inputbar-fg = "#${base05}";
        inputbar-bg = "#${base00}";
        recolor-lightcolor = "#${base00}";
        recolor-darkcolor = "#${base05}";
        index-fg = "#${base05}";
        index-bg = "#${base00}";
        index-active-fg = "#${base05}";
        index-active-bg = "#${base02}";
        render-loading-bg = "#${base00}";
        render-loading-fg = "#${base05}";
        highlight-color = "#${base0D}";
        highlight-fg = "#${base0F}";
        highlight-active-color = "#${base0F}";
      };
      mappings = {
        i = "zoom in";
        o = "zoom out";
      };
    };
  };
}
