{ lib
, pkgs
, writeShellApplication
, ...
}:

with lib;

writeShellApplication
{
  name = "mon-brightness-control";
  meta = {
    mainProgram = "mon-brightness-control";
    platforms = platforms.linux;
  };

  runtimeInputs = with pkgs; [
    libnotify
    brightnessctl
  ];

  checkPhase = "";

  text = let
    changePercentage = 5;
  in /* bash */ ''

    # Script to control brightness of screen
    get_brightness_percentage() {
      brightnessctl --machine-readable --exponent info | cut --fields=4 --delimiter=, | tr --delete '%'
    }

    notify_brightness() {
      notify-send --hint string:x-canonical-private-synchronous:mon-brightness-control --hint int:value:$(get_brightness_percentage)  --icon display-brightness-high-symbolic "Monitor brightness" $1
    }

    increase_brightness() {
      brightnessctl --quiet --exponent set ${toString changePercentage}%+
      notify_brightness "increased"
    }

    decrease_brightness() {
      brightnessctl --quiet set --exponent ${toString changePercentage}%-
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
