#!/usr/bin/sh

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
  sleep 0.5
  color=$(hyprpicker --autocopy | rg '^#\w+')
else
  color=$(colorpicker --one-shot | rg "Hex: (.+)" -or '$1')
  printf "%s" $color | xclip -sel copy
fi

notify-send "Colorpicker" "$color" -u low
