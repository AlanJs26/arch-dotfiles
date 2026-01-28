#!/usr/bin/sh

case "$XDG_CURRENT_DESKTOP" in
"Hyprland" | "niri")
  hyprshot --raw -m region | tesseract stdin - -l por | wl-copy
  ;;
*)
  maim -s -u | tesseract stdin - -l por | xclip -selection clipboard
  ;;
esac

notify-send tesseract "Copied to clipboard!"
