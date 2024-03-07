#!/usr/bin/bash


mode="$($TOOLS/setup-monitors.sh --list|awk 'BEGIN{print "auto"};{print}'|rofi -dmenu -p 'monitors')"

if [ -n "$mode" ]; then
    $TOOLS/setup-monitors.sh "$mode"
    
    # set wallpaper
    feh --bg-fill "$BSPDIR/wallpapers/hell3.png"

    # reload statusbar
    $HOME/.config/polybar/launch.sh --tokyonight 
fi

