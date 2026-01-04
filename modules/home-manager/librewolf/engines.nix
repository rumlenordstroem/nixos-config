{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.librewolf;
  updateInterval = 24 * 60 * 60 * 1000; # Updates icons once per day
in {
  config = mkIf cfg.enable {
    programs.librewolf.profiles.default.search = {
      default = "ddg";
      force = true;
      engines = {
        # Disable stuff I do not use
        google.metaData.hidden = true;
        bing.metaData.hidden = true;

        nix-packages = {
          name = "Nix Packages";
          urls = [ {
            template = "https://search.nixos.org/packages";
            params = [
              { name = "type"; value = "packages"; }
              { name = "channel"; value = "unstable"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          } ];

          icon = "https://nixos.org/favicon.png";
          inherit updateInterval;
          definedAliases = ["@np"];
        };

        nix-options = {
          name = "Nix Options";
          urls = [ {
            template = "https://search.nixos.org/options";
            params = [
              { name = "type"; value = "packages"; }
              { name = "channel"; value = "unstable"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          } ];

          icon = "https://nixos.org/favicon.png";
          inherit updateInterval;
          definedAliases = ["@no"];
        };

        aoty = {
          name = "AOTY";
          urls = [ {
            template = "https://www.albumoftheyear.org/search";
            params = [ { name = "q"; value = "{searchTerms}"; } ];
          } ];

          icon = "https://cdn.albumoftheyear.org/images/favicon.png";
          inherit updateInterval;
          definedAliases = ["@aoty"];
        };

        ddo = {
          name = "Den Danske Ordbog";
          urls = [ {
            template = "https://ordnet.dk/ddo/ordbog";
            params = [ { name = "query"; value = "{searchTerms}"; } ];
          } ];

          icon = "https://ordnet.dk/favicon.ico";
          inherit updateInterval;
          definedAliases = ["@ddo"];
        };

        github = {
          name = "GitHub";
          urls = [ {
            template = "https://github.com/search";
            params = [ { name = "q"; value = "{searchTerms}"; } ];
          } ];

          icon = "https://github.githubassets.com/favicons/favicon-dark.png";
          inherit updateInterval;
          definedAliases = ["@gh"];
        };

        wikipedia = {
          name = "Wikipedia";
          urls = [ {
            template = "https://en.wikipedia.org";
            params = [ { name = "search"; value = "{searchTerms}"; } ];
          } ];

          icon = "https://en.wikipedia.org/static/favicon/wikipedia.ico";
          inherit updateInterval;
          definedAliases = ["@wp"];
        };

        wiktionary = {
          name = "Wiktionary";
          urls = [ {
            template = "https://en.wiktionary.org";
            params = [ { name = "search"; value = "{searchTerms}"; } ];
          } ];

          icon = "https://en.wiktionary.org/static/favicon/wiktionary/en.ico";
          inherit updateInterval;
          definedAliases = ["@wt"];
        };

        dba = {
          name = "DBA";
          urls = [ {
            template = "https://www.dba.dk/soeg";
            params = [ { name = "soeg"; value = "{searchTerms}"; } ];
          } ];

          icon = "https://dbastatic.dk/Content/dba.ico";
          inherit updateInterval;
          definedAliases = ["@dba"];
        };
      };
    };
  };
}
