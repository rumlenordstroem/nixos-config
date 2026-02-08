{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.wayland-session;
in
{
  options.wayland-session.enable = mkEnableOption "Wayland session";

  config = mkIf cfg.enable (mkMerge [
      # Use this module from nixpkgs
      (import "${inputs.nixpkgs}/nixos/modules/programs/wayland/wayland-session.nix" { inherit lib pkgs; enableXWayland = false; })
    {
      # Allow users group to request realtime priority
      security.pam.loginLimits = [{ domain = "@users"; item = "rtprio"; type = "-"; value = 1; }];

      # https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1050913
      xdg.portal.config.sway.default = [ "wlr" "gtk" ];
    }
  ]);
}
