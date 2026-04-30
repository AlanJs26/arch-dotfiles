#!/usr/bin/env bash

small_monitor="$(bspmonitors query --monitor secundary)"
big_monitor="$(bspmonitors query --monitor primary)"
tv_monitor="$(bspmonitors query --monitor tv)"

if [ -z "$1" ]; then
    if [ -e /tmp/active-monitor-mode ]; then
        mode="$(cat /tmp/active-monitor-mode)"
    else
        mode="SmallBig"
    fi
else
    mode="$1"
fi


case "$mode" in
    "--list")
        bspmonitors --list_layouts
        ;;
    "auto")
        bspmonitors auto
        echo "$mode" > /tmp/active-monitor-mode
        ;;
    *)
        if [ "$(bspmonitors check $mode)" = "available" ] && bspmonitors layout $mode; then
            echo "$mode" > /tmp/active-monitor-mode
        else
            old_mode="$(cat /tmp/active-monitor-mode)"
            if [ -e /tmp/active-monitor-mode ] && [ "$old_mode" != "$mode" ]; then
                echo "\"$mode\" is unavailable. Going back to \"$old_mode\" layout"
                notify-send bspmonitors "\"$mode\" is unavailable. Going back to \"$old_mode\" layout"
                bspmonitors layout $old_mode
            else
                echo "\"$mode\" is unavailable. Using automatic config"
                notify-send bspmonitors "\"$mode\" is unavailable. Using automatic config"
                bspmonitors auto
                echo "auto" > /tmp/active-monitor-mode
            fi
        fi
esac


if ! [ -e /tmp/active-monitor-mode ]; then
    while [ "$(bspc query -M -m focused --names)" != "$big_monitor" ]; do
        sleep 4
        bspc config pointer_follows_monitor true
        bspc monitor -f $big_monitor
        bspc config pointer_follows_monitor false
    done
fi

# xrandr --output DisplayPort-0 --primary --mode 1920x1080 --output HDMI-A-0 --mode 1920x1080 --same-as DisplayPort-0
# xrandr --output DisplayPort-1 --mode 1360x768 --pos 0x312 --output DisplayPort-1-0 --mode 1920x1080 --primary --pos 1360x0 --output $tv_monitor --mode 1280x720 --pos 3282x0  
# xrandr --output DisplayPort-1 --mode 1360x768 --pos 0x312 --output DisplayPort-1-0 --mode 1920x1080 --pos 1360x0
