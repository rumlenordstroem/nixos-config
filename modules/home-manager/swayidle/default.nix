{ inputs, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.nix-pille.services.swayidle;
in
{
  options.nix-pille.services.swayidle = {
    enable = mkEnableOption {
      name = "nix pille swayidle configuration";
    };
  };

  config = mkIf cfg.enable {
    services.swayidle = let 
      inactiveTime = 900; # Seconds idle before going to sleep
      swaylock = "${config.programs.swaylock.package}/bin/swaylock";
      execWhenLocked = command: "if ${pkgs.procps}/bin/pgrep --exact --full ${swaylock}; then ${command}; fi";
      swaymsg = "${config.wayland.windowManager.sway.package}/bin/swaymsg";
      outputPower = "${swaymsg} output \"*\" power";
      powerOff = "${outputPower} off && ${pkgs.brightnessctl}/bin/brightnessctl --quiet --device='*kbd_backlight' --save set 0";
      powerOn = "${outputPower} on && ${pkgs.brightnessctl}/bin/brightnessctl --quiet --device='*kbd_backlight' --restore";
    in {
      enable = true;

      timeouts = [
        # For when the inactive time has already been reached and display is locked. It should then quickly power off display if user remains inactive
        { timeout = 10; command = execWhenLocked powerOff; resumeCommand = execWhenLocked powerOn; }

        # Timeout for locking windown manager
        { timeout = inactiveTime; command = swaylock; }

        # Timeout for powering off displays
        { timeout = inactiveTime + 10; command = powerOff; resumeCommand = powerOn; }
      ];
    };

    # Fix
    systemd.user.services.swayidle.Service.Restart = mkForce "on-failure";
    systemd.user.services.swayidle.Service.RestartSec = 3;
  };
}
