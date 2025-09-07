{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.fzf;
in
{
  options.nix-pille.programs.fzf = {
    enable = mkEnableOption {
      name = "nix pille fzf configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;

      defaultCommand = "${pkgs.fd}/bin/fd --type file --follow";
      defaultOptions = [
        "--height=60%"
        "--layout=reverse"
        "--info=right"
        "--border=sharp"
        "--preview-window=border-sharp"
        "--no-scrollbar"
        "--no-separator"
        "--margin=1"
        "--info=hidden"
      ];

      fileWidgetCommand = "${pkgs.fd}/bin/fd --type file --follow";
      fileWidgetOptions = [
        " --preview '${pkgs.bat}/bin/bat -n --color=always {}'"
      ];

      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type directory --follow";
      changeDirWidgetOptions = [
        "--preview '${config.programs.eza.package}/bin/eza --tree --color=always --icons=always {}'"
      ];

      colors = with config.colorScheme.palette; {
        "fg" = "#${base05}";
        "bg" = "#${base00}";
        "hl" = "#${base08}";
        "fg+" = "#${base05}";
        "bg+" = "#${base02}";
        "gutter" = "#${base00}";
        "hl+" = "#${base08}";
        "query" = "#${base05}";
        "disabled" = "#${base05}";
        "info" = "#${base04}";
        "border" = "#${base04}";
        "scrollbar" = "#${base04}";
        "preview-border" = "#${base04}";
        "preview-scrollbar" = "#${base04}";
        "separator" = "#${base04}";
        "label" = "#${base04}";
        "preview-label" = "#${base04}";
        "prompt" = "#${base0E}";
        "pointer" = "#${base06}";
        "marker" = "#${base06}";
        "spinner" = "#${base06}";
        "header" = "#${base06}";
      };
    };
  };
}
