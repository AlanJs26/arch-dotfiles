#!/usr/bin/sh

case "$XDG_CURRENT_DESKTOP" in
"Hyprland")
  sleep 0.5
  color=$(hyprpicker --autocopy | rg '^#\w+')
  ;;
"niri")
  sleep 0.5
  color=$(hyprpicker --autocopy | rg '^#\w+')
  ;;
*)
  color=$(colorpicker --one-shot | rg "Hex: (.+)" -or '$1')
  printf "%s" $color | xclip -sel copy
  ;;
esac

notify-send "Colorpicker" "$color" -u low
