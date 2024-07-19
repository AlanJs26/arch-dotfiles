#!/usr/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<EOF
Helper script that spawns rofi-file-explorer given a zoxide query

Usage:
    rofi-zoxide.sh
EOF
    exit 0
fi

results=$(rofi -dmenu -theme "~/.config/rofi/tokyonight/rofi-input.rasi" -p "zoxide")

results=$(zoxide query -l|fzf --filter="$results"|head -n1)

if [ -z "$results" ]; then
    exit
fi

rofi -show file-browser-extended -file-browser-dir "$results" -file-browser-cmd "$TOOLS/run.sh"
