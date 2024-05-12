#!/usr/bin/bash

results=$(rofi -dmenu -theme "~/.config/rofi/tokyonight/rofi-input.rasi" -p "zoxide")

if [ -z "$results" ]; then
    exit
fi

results=$(zoxide query -l $results|head -n1)


rofi -show file-browser-extended -file-browser-dir "$results" -file-browser-cmd "$TOOLS/run.sh"
