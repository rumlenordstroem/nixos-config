{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.programs.librewolf;
in {
  config = mkIf cfg.enable {
    programs.librewolf.profiles.default = {
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "svg.context-properties.content.enabled" = true;
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = true;
      };

      extensions = {
        force = true;
        packages = with pkgs.nur.repos.rycee.firefox-addons; [ firefox-color ];
        settings."FirefoxColor@mozilla.com".settings = {
          firstRunDone = true;
          theme = {
            title = config.colorScheme.name;
            colors =

            with config.colorScheme.palette;

            let
              mkColor = color:
              let
                inherit (inputs.nix-colors.lib.conversions) hexToRGB;
                rgb = hexToRGB color;
              in {
                r = builtins.elemAt rgb 0;
                g = builtins.elemAt rgb 1;
                b = builtins.elemAt rgb 2;
              };
            in {
              toolbar = mkColor base00;
              toolbar_text = mkColor base05;
              frame = mkColor base01;
              tab_background_text = mkColor base05;
              toolbar_field = mkColor base02;
              toolbar_field_text = mkColor base05;
              tab_line = mkColor base0D;
              popup = mkColor base00;
              popup_text = mkColor base05;
              button_background_active = mkColor base04;
              frame_inactive = mkColor base00;
              icons_attention = mkColor base0D;
              icons = mkColor base05;
              ntp_background = mkColor base00;
              ntp_text = mkColor base05;
              popup_border = mkColor base0D;
              popup_highlight_text = mkColor base05;
              popup_highlight = mkColor base04;
              sidebar_border = mkColor base0D;
              sidebar_highlight_text = mkColor base05;
              sidebar_highlight = mkColor base0D;
              sidebar_text = mkColor base05;
              sidebar = mkColor base00;
              tab_background_separator = mkColor base0D;
              tab_loading = mkColor base05;
              tab_selected = mkColor base00;
              tab_text = mkColor base05;
              toolbar_bottom_separator = mkColor base00;
              toolbar_field_border_focus = mkColor base0D;
              toolbar_field_border = mkColor base00;
              toolbar_field_focus = mkColor base00;
              toolbar_field_highlight_text = mkColor base00;
              toolbar_field_highlight = mkColor base0D;
              toolbar_field_separator = mkColor base0D;
              toolbar_vertical_separator = mkColor base0D;
            };
          };
        };
      };

      userChrome = /* css */ ''
        /* Menu button */
        #PanelUI-button {
          -moz-box-ordinal-group: 0 !important;
          order: -2 !important;
          margin: 2px !important;
        }

        /* Bookmark toolbar */
        #PersonalToolbar{
          display: none !important;
        }

        /* Window control buttons (min, resize and close) */
        .titlebar-buttonbox-container {
          display: none !important;
          margin-right: 12px !important;
        }

        /* Page back and foward buttons */
        #back-button,
        #forward-button
        {
          display: none !important
        }

        /* Extension name inside URL bar */
        #identity-box.extensionPage #identity-icon-label {
          visibility: collapse !important
        }

        /* All tabs (v-like) button */
        #alltabs-button {
          display: none !important
        }

        /* URL bar icons */
        #identity-permission-box,
        #star-button-box,
        #identity-icon-box,
        #picture-in-picture-button,
        #tracking-protection-icon-container,
        #reader-mode-button,
        #translations-button
        {
          display: none !important
        }

        /* "This time search with:..." */
        #urlbar .search-one-offs {
          display: none !important
        }

        /* Space before and after tabs */
        .titlebar-spacer {
          display: none;
        }

        /* --- ~END~ element visibility section --- */

        /* Navbar size calc */
        :root{
        --tab-border-radius: 6px !important; /*  Tab border radius -- Changes the tabs rounding  *//*  Default: 6px  */
        --NavbarWidth: 43; /*  Default values: 36 - 43  */
        --TabsHeight: 36; /*  Minimum: 30  *//*  Default: 36  */
        --TabsBorder: 8; /*  Doesnt do anything on small layout  *//*  Default: 8  */
        --NavbarHeightSmall: calc(var(--TabsHeight) + var(--TabsBorder))  /*  Only on small layout  *//*  Default: calc(var(--TabsHeight) + var(--TabsBorder))  *//*  Default as a number: 44  */}

        @media screen and (min-width:1325px)    /*  Only the tabs space will grow from here  */
        {:root #nav-bar{margin-top: calc(var(--TabsHeight) * -1px - var(--TabsBorder) * 1px)!important; height: calc(var(--TabsHeight) * 1px + var(--TabsBorder) * 1px)} #TabsToolbar{margin-left: calc(1325px / 100 * var(--NavbarWidth)) !important} #nav-bar{margin-right: calc(100vw - calc(1325px / 100 * var(--NavbarWidth))) !important; vertical-align: center !important} #urlbar-container{min-width: 0px !important;  flex: auto !important} toolbarspring{display: none !important}}

        @media screen and (min-width:950px) and (max-width:1324px)    /*  Both the tabs space and the navbar will grow  */
        {:root #nav-bar{margin-top: calc(var(--TabsHeight) * -1px - var(--TabsBorder) * 1px) !important; height: calc(var(--TabsHeight) * 1px + var(--TabsBorder) * 1px)} #TabsToolbar{margin-left: calc(var(--NavbarWidth) * 1vw) !important} #nav-bar{margin-right: calc(100vw - calc(var(--NavbarWidth) * 1vw)) !important; vertical-align: center !important} #urlbar-container{min-width: 0px !important;  flex: auto !important} toolbarspring{display: none !important} #TabsToolbar, #nav-bar{transition: margin-top .25s !important}}

        @media screen and (max-width:949px)    /*  The window is not enough wide for a one line layout  */
        {:root #nav-bar{padding: 0 5px 0 5px!important; height: calc(var(--NavbarHeightSmall) * 1px) !important} toolbarspring{display: none !important;} #TabsToolbar, #nav-bar{transition: margin-top .25s !important}}
        #nav-bar, #PersonalToolbar{background-color: #0000 !important;background-image: none !important; box-shadow: none !important} #nav-bar{margin-left: 3px;} .tab-background, .tab-stack { min-height: calc(var(--TabsHeight) * 1px) !important}

        /*  Removes urlbar border/background  */
        #urlbar-background {
          border: none !important;
          outline: none !important;
          transition: .15s !important;
        }

        /*  Removes the background from the urlbar while not in use  */
        #urlbar:not(:hover):not([breakout][breakout-extend]) > #urlbar-background {
          box-shadow: none !important;
          background: #0000 !important;
        }

        /*  Removes annoying border  */
        #navigator-toolbox {
          border: none !important
        }

        /* Fades window while not in focus */
        #navigator-toolbox-background:-moz-window-inactive {
          filter: contrast(90%)
        }

        /* Remove fullscreen warning border */
        #fullscreen-warning {
          border: none !important;
          background: -moz-Dialog !important;
        }

        /*  Tabs close button  */
        .tabbrowser-tab:not(:hover) .tab-close-button {
          opacity: 0% !important;
          transition: 0.3s !important;
          display: -moz-box !important;
        }
        .tab-close-button[selected]:not(:hover) {
          opacity: 45% !important;
          transition: 0.3s !important;
          display: -moz-box !important;
        }
        .tabbrowser-tab:hover .tab-close-button {
          opacity: 50%;
          transition: 0.3s !important;
          background: none !important;
          cursor: pointer;
          display: -moz-box !important;
        }
        .tab-close-button:hover {
          opacity: 100% !important;
          transition: 0.3s !important;
          background: none !important;
          cursor: pointer;
          display: -moz-box !important;
        }
        .tab-close-button[selected]:hover {
          opacity: 100% !important;
          transition: 0.3s !important;
          background: none !important;
          cursor: pointer;
          display: -moz-box !important;
        }
        '';
    };
  };
}
