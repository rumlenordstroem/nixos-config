{ inputs, config, lib, pkgs, ... }:
{
  # See https://docs.helix-editor.com/themes.html
  base16 = with config.colorScheme.palette; {
    # Syntax highlighting
    "attributes" = "#${base0D}";
    "comment" = { fg = "#${base03}"; modifiers = ["italic"]; };
    "constant" = "#${base09}";
    "constant.character.escape" = "#${base0C}";
    "constant.numeric" = "#${base09}";
    "constructor" = "#${base0D}";
    "diff.delta" = "#${base0A}";
    "diff.minus" = "#${base08}";
    "diff.plus" = "#${base0B}";
    "function" = "#${base0D}";
    "keyword" = "#${base0E}";
    "label" = "#${base0A}";
    "namespace" = { fg = "#${base05}"; modifiers = ["italic"]; };
    "operator" = "#${base0C}";
    "punctuation" = { fg = "#${base05}"; modifiers = ["dim"]; };
    "punctuation.special" = "#${base0C}";
    "special" = "#${base0C}";
    "string"  = "#${base0B}";
    "type" = "#${base0A}";
    "variable" = "#${base05}";
    "variable.builtin" = { fg = "#${base08}"; modifiers = ["italic"]; };
    "variable.parameter" = { fg = "#${base08}"; };
    "variable.other.member" = "#${base0C}";

    "error" = "#${base08}";
    "warning" = "#${base09}";
    "info" = "#${base0D}";
    "hint" = "#${base0C}";
    "debug" = "#${base03}";

    # Markup highlighting
    "markup.bold" = { fg = "#${base0A}"; modifiers = ["bold"]; };
    "markup.heading" = "#${base0D}";
    "markup.italic" = { fg = "#${base0E}"; modifiers = ["italic"]; };
    "markup.link.text" = "#${base08}";
    "markup.link.url" = { fg = "#${base09}"; modifiers = ["underlined"]; };
    "markup.list" = "#${base08}";
    "markup.quote" = "#${base0C}";
    "markup.raw" = "#${base0B}";
    "markup.strikethrough" = { modifiers = ["crossed_out"]; };

    # Diagnostics coloring
    "diagnostic" = { modifiers = ["underlined"]; };
    "diagnostic.hint" = { underline = { style = "curl"; }; };
    "diagnostic.info" = { underline = { style = "curl"; }; };
    "diagnostic.warning" = { underline = { style = "curl"; }; };
    "diagnostic.error" = { underline = { style = "curl"; }; };

    # Cursor coloring
    "ui.cursor" = { fg = "#${base00}"; bg = "#${base05}"; };
    "ui.cursor.insert" = { fg = "#${base05}"; modifiers = ["reversed"]; };
    "ui.cursor.match" = "#${base09}";
    "ui.cursor.select" = { fg = "#${base05}"; modifiers = ["reversed"]; };
    "ui.cursorline.primary" = { fg = "#${base05}"; bg = "#${base01}"; };
    "ui.cursorline.secondary" = { fg = "#${base05}"; bg = "#${base01}"; };
    "ui.selection" = { bg = "#${base02}"; };
    "ui.selection.primary" = { bg = "#${base02}"; };

    # General UI elements
    "ui.background" = { bg = "#${base00}"; };
    "ui.bufferline" = { fg = "#${base04}"; bg = "#${base01}"; };
    "ui.bufferline.active" = { fg = "#${base00}"; bg = "#${base03}"; };
    "ui.linenr" = "#${base04}";
    "ui.linenr.selected" = "#${base05}";
    "ui.menu" = { fg = "#${base05}"; bg = "#${base01}"; };
    "ui.menu.scroll" = { fg = "#${base03}"; bg = "#${base01}"; };
    "ui.menu.selected" = { fg = "#${base05}"; bg = "#${base02}"; modifiers = ["bold"]; };
    "ui.help" = { fg = "#${base05}"; bg = "#${base01}"; };
    "ui.popup" = { bg = "#${base01}"; };
    "ui.statusline" = { fg = "#${base04}"; bg = "#${base01}"; };
    "ui.statusline.inactive" = { bg = "#${base01}"; fg = "#${base03}"; };
    "ui.statusline.insert" = { fg = "#${base00}"; bg = "#${base0B}"; };
    "ui.statusline.normal" = { fg = "#${base00}"; bg = "#${base03}"; };
    "ui.statusline.select" = { fg = "#${base00}"; bg = "#${base0F}"; };
    "ui.text" = "#${base05}";
    "ui.text.focus" = { fg = "#${base05}"; bg = "#${base02}"; modifiers = ["bold"]; };
    "ui.virtual.indent-guide" = { fg = "#${base02}"; };
    "ui.virtual.inlay-hint" = { fg = "#${base03}"; bg = "#${base01}"; };
    "ui.virtual.jump-label" = { fg = "#${base09}"; modifiers = ["bold"]; };
    "ui.virtual.ruler" = { bg = "#${base01}"; };
    "ui.window" = { bg = "#${base04}"; };
  };
}
