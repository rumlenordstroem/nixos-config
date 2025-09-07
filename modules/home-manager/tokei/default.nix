{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.tokei;

  tomlFormat = pkgs.formats.toml { };
in
{
  options = {
    nix-pille.programs.tokei = {
      enable = mkEnableOption "nix pille tokei configuration";

      package = mkOption {
        type = types.package;
        default = pkgs.tokei;
        defaultText = literalExpression "pkgs.tokei";
        description = "The Tokei package to install.";
      };

      settings = mkOption {
        type = tomlFormat.type;
        default = { };
        example = literalExpression ''
          {
            columns = 80;
            sort = "lines";
            types = ["Python"];
            treat_doc_strings_as_comments = true;
          }
        '';
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/tokei/tokei.toml`
          See <https://github.com/XAMPPRocky/tokei#configuration>
          for more info.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."tokei/tokei.toml" = lib.mkIf (cfg.settings != { }) {
      source = tomlFormat.generate "tokei-config" cfg.settings;
    };
  };
}
