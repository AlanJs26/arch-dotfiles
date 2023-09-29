#!/usr/bin/sh

color=$(colorpicker --one-shot|rg "Hex: (.+)" -or '$1')
printf "%s" $color|xclip -sel copy
notify-send "Colorpicker" "$color" -u low
