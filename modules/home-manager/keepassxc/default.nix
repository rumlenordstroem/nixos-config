{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.keepassxc;
in
{
  config = mkIf cfg.enable {
    programs.keepassxc = {
      settings = {
        General.ConfigVersion = 2;
        Browser = {
          Enabled = true;
          UseCustomBrowser = true;
          CustomBrowserType = 2; # Firefox
          CustomBrowserLocation = "~/.librewolf/native-messaging-hosts/";
          UpdateBinaryPath = false; # Needed for browser plugin
        };
        GUI.ApplicationTheme = config.colorScheme.variant;
        Security.IconDownloadFallback = true;
        PasswordGenerator = {
          Length = 32;
          SpecialChars = true;
        };
      };
    };

    # Browser extension
    programs.librewolf = {
      nativeMessagingHosts = [ pkgs.keepassxc ];

      profiles = {
        default.extensions = {
          packages = with pkgs.nur.repos.rycee.firefox-addons; [
            keepassxc-browser
          ];
          # See settings https://github.com/keepassxreboot/keepassxc-browser/blob/develop/keepassxc-browser/background/page.js
          settings."keepassxc-browser@keepassxc.org".settings.settings = {
              "defaultGroup" = "Accounts";
              "downloadFaviconAfterSave" = true;
              "saveDomainOnlyNewCreds" = true;
          };
        };
      };
    };
  };
}
