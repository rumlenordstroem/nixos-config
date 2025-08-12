{ inputs, config, lib, pkgs, ... }:
{
  # Hardware accelerated video
  "media.ffmpeg.vaapi.enabled" = true;

  # Enable DRM
  "media.eme.enabled" = true;

  # Enable WebGL
  "webgl.disabled" = false;

  # UI stuff
  "browser.download.autohidebuttton" = false;
  "browser.aboutwelcome.enabled" = false;
  "browser.translations.automaticallyPopup" = false;
  "identity.fxaccounts.toolbar.enabled" = false;

  # For CSS and UI customization
  "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  "devtools.chrome.enabled" = true;
  "devtools.debugger.remote-enabled" = true;
  "browser.uiCustomization.state" = builtins.toJSON {
    currentVersion = 23;
    # Place extensions in the extensions menu
    placements.unified-extensions-area = [
      "sponsorblocker_ajay_app-browser-action"
      "ublock0_raymondhill_net-browser-action"
      "addon_darkreader_org-browser-action"
      "jid1-tsgsxbhncspbwq_jetpack-browser-action"
    ];
  };

  # Enable extensions by default
  "extensions.autoDisableScopes" = 0;

  # Enable cookies and cache
  "browser.cache.disk.enable" = true;
  "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
  "privacy.clearOnShutdown_v2.cache" = false;

  # Allow website to detect system theme
  "privacy.resistFingerprinting" = false;
  "privacy.fingerprintingProtection" = true;
  "privacy.fingerprintingProtection.overrides" = "+AllTargets,-CSSPrefersColorScheme,-JSDateTimeUTC";

  # Change default geo location API
  "geo.provider.use_geoclue" = true;
}
