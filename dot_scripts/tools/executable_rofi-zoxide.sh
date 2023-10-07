#!/usr/bin/bash

results=$(rofi -dmenu -theme "~/.config/rofi/tokyonight/rofi-input.rasi" -p "zoxide"|xargs -i zoxide query -l "{}"|head -n1)

if [ -z "$results" ]; then
    exit
fi


rofi -show file-browser-extended -file-browser-dir "$results" -file-browser-cmd "$TOOLS/run.sh"
