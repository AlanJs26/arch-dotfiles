#!/bin/bash

tmpfile=$(mktemp tmp.XXXX.png)

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
  grim -t png -g "$(slurp)" "$tmpfile"
else
  maim -u -s "$tmpfile"
fi

if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
  rapid_latex_ocr "$tmpfile" | rg 'cost: [0-9.]+$' -v | wl-copy
else
  rapid_latex_ocr "$tmpfile" | rg 'cost: [0-9.]+$' -v | xclip -selection copy
fi

rm $tmpfile

notify-send 'Latex OCR' "Copied to clipboard!"
