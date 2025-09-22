#!/usr/bin/sh

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
  hyprshot --raw -m region | tesseract stdin - -l por | wl-copy
else
  maim -s -u | tesseract stdin - -l por | xclip -selection clipboard
fi

notify-send tesseract "Copied to clipboard!"
