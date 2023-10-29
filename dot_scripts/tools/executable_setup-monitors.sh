#!/usr/bin/env bash


if [ -z "$1" ]; then
    if [ -e /tmp/active-monitor-mode ]; then
        mode="$(cat /tmp/active-monitor-mode)"
    else
        mode="SmallBig_TV"
    fi
else
    mode="$1"
    echo "$mode" > /tmp/active-monitor-mode
fi

small_monitor="$(bspmonitors query --monitor secundary)"
big_monitor="$(bspmonitors query --monitor primary)"
tv_monitor="$(bspmonitors query --monitor tv)"

case "$mode" in
    "--list")
        bspmonitors --list_layouts
        ;;
    *)
        bspmonitors layout $mode
esac


if [ -z "$1" ] && ! [ -e /tmp/active-monitor-mode ]; then
    bspc config pointer_follows_monitor true
    bspc monitor -f $big_monitor
    bspc config pointer_follows_monitor false
fi

# xrandr --output DisplayPort-0 --primary --mode 1920x1080 --output HDMI-A-0 --mode 1920x1080 --same-as DisplayPort-0
# xrandr --output DisplayPort-1 --mode 1360x768 --pos 0x312 --output DisplayPort-1-0 --mode 1920x1080 --primary --pos 1360x0 --output $tv_monitor --mode 1280x720 --pos 3282x0  
# xrandr --output DisplayPort-1 --mode 1360x768 --pos 0x312 --output DisplayPort-1-0 --mode 1920x1080 --pos 1360x0
