{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.helix;
in
{
  options.nix-pille.programs.helix = {
    enable = mkEnableOption {
      name = "nix pille helix configuration";
    };
  };

  config = mkIf cfg.enable {
    programs.helix = {
      enable = true;

      defaultEditor = true;
      settings = {
        editor = {
          bufferline = "multiple";
          color-modes = true;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "block";
          };
          cursorline = true;
          file-picker.hidden = false;
          idle-timeout = 0;
          indent-guides.render = true;
          line-number = "relative";
          lsp.display-messages = true;
          lsp.display-inlay-hints = true;
          scrolloff = 8;
          shell = [ "fish" "-c" ];

          # Diagnostics
          end-of-line-diagnostics = "hint";
          inline-diagnostics.cursor-line = "error";
  
          statusline = {
            center = [
              "file-name"
              "file-modification-indicator"
            ];
            left = [ "mode" ];
            mode = {
              insert = "INSERT";
              normal = "NORMAL";
              select = "SELECT";
            };
            right = [
              "spinner"
              "diagnostics"
              "position"
              "spacer"
              "position-percentage"
              "spacer"
              "file-encoding"
              "file-line-ending"
              "file-type"
            ];
          };
          whitespace = {
            render = {
              newline = "none";
              space = "none";
              tab = "all";
            };
          };
        };
        keys = {
          insert = {
            S-A-down = "copy_selection_on_next_line";
            S-A-up = "copy_selection_on_prev_line";
            down = "no_op";
            end = "no_op";
            home = "no_op";
            left = "no_op";
            pagedown = "no_op";
            pageup = "no_op";
            right = "no_op";
            up = "no_op";
          };
          normal = {
            S-A-down = "copy_selection_on_next_line";
            S-A-up = "copy_selection_on_prev_line";
            S-tab = "unindent";
            X = "extend_line_above";
            down = "no_op";
            end = "no_op";
            home = "no_op";
            left = "no_op";
            pagedown = "no_op";
            pageup = "no_op";
            right = "no_op";
            tab = "indent";
            up = "no_op";
          };
        };
        theme = "base16";
      };
  
      themes = (import ./theme.nix { inherit inputs config lib pkgs; });

      languages = (import ./languages.nix { inherit inputs config lib pkgs; });
    };
  };
}
