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
      # Timing
      seconds = 1;
      minutes = 60 * seconds;
      timeBeforeLock = 5 * minutes; # Time idle before locking
      timeBeforeSuspend = 10 * minutes;

      # Programs
      swaylock = "${config.programs.swaylock.package}/bin/swaylock --image $(${config.services.swww.package}/bin/swww query | ${pkgs.coreutils}/bin/cut --delimiter ' ' --fields 9)";
      loginctl = "${pkgs.systemd}/bin/loginctl";
      lock = "${loginctl} lock-session";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      suspend = "${systemctl} suspend";
      kbdBacklight = "${pkgs.brightnessctl}/bin/brightnessctl --quiet --device='*kbd_backlight'";

      # Functions
      display = status: "${pkgs.niri}/bin/niri msg action power-${status}-monitors";
      lockDependentCommand = { locked, command }: "if [ $(${loginctl} show-session $XDG_SESSION_ID -P LockedHint) = ${locked} ]; then ${command}; fi;";
    in {
      enable = true;

      timeouts = [
        {
          timeout = 15 * seconds;
          command = lockDependentCommand { locked = "yes"; command = display "off"; };
        }
        {
          timeout = timeBeforeLock - (15 * seconds);
          command = display "off";
          resumeCommand = display "on";
        }
        {
          timeout = timeBeforeLock;
          command = lockDependentCommand { locked = "no"; command = lock; };
        }
        {
          timeout = timeBeforeSuspend;
          command = suspend;
        }
      ];

      events = {
          "before-sleep" = "${lock}; ${display "off"}; ${kbdBacklight} --save set 0";
          "after-resume" = "${display "on"}; ${kbdBacklight} --restore";
          "lock" = swaylock;
          "unlock" = display "on";
      };
    };

    # Fix
    systemd.user.services.swayidle.Service.Restart = mkForce "on-failure";
    systemd.user.services.swayidle.Service.RestartSec = 3;
  };
}
