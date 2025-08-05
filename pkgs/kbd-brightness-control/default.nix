{ lib
, pkgs
, writeShellApplication
, ...
}:

with lib;

writeShellApplication
{
  name = "kbd-brightness-control";
  meta = {
    mainProgram = "kbd-brightness-control";
    platforms = platforms.linux;
  };

  runtimeInputs = with pkgs; [
    libnotify
    brightnessctl
  ];

  checkPhase = "";

  text = let
    changePercentage = 5;
    device = "*kbd_backlight"; # Find with 'brightnessctl --list'
  in /* bash */ ''

    # Script to control brightness of keyboard
    get_brightness_percentage() {
      brightnessctl --machine-readable --exponent --device='${device}' info | cut --fields=4 --delimiter=, | tr --delete '%'
    }

    notify_brightness() {
      notify-send --hint string:x-canonical-private-synchronous:kbd-brightness-control --hint int:value:$(get_brightness_percentage)  --icon keyboard-brightness-symbolic "Keyboard brightness" $1
    }

    increase_brightness() {
      brightnessctl --quiet --device='${device}' set ${toString changePercentage}%+
      notify_brightness "increased"
    }

    decrease_brightness() {
      brightnessctl --quiet --device='${device}' set ${toString changePercentage}%-
      notify_brightness "decreased"
    }

    case $1 in
      increase)
        increase_brightness
      ;;
      decrease)
        decrease_brightness
      ;;
      *)
        echo "Run script with correct argument:\n$0 <increase|decrease>"
        exit 1
      ;;
    esac
  '';
}
