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

small_monitor="DP-2"
big_monitor="DP-1-1"
tv_monitor="HDMI-1-1"


case "$mode" in
    "--list")
        echo "SmallBig
SmallBig_TV
SmallBigTV
BigTV
Big
Small
TV"
        ;;
    SmallBig)
        xrandr --output $small_monitor  --primary --mode 1360x768 --pos 0x312 --output $big_monitor           --mode 1920x1080 --pos 1360x0 --output $tv_monitor --off
        # xrandr --output $small_monitor            --mode 1360x768 --pos 0x312 --output $big_monitor --primary --mode 1920x1080 --pos 1360x0 --output $tv_monitor --off
        bspc monitor $big_monitor -d 1 2 3 4
        bspc monitor $small_monitor -d 5 6 7 8
        ;;
    SmallBig_TV)
        xrandr --output $small_monitor --primary --mode 1360x768 --pos 0x312 --output $big_monitor           --mode 1920x1080 --pos 1360x0 --output $tv_monitor                  --pos 3280x0 --same-as $big_monitor
        xrandr --output $small_monitor            --mode 1360x768 --pos 0x312 --output $big_monitor --primary --mode 1920x1080 --pos 1360x0 --output $tv_monitor --mode 1920x1080 --pos 3280x0 --same-as $big_monitor
        bspc monitor $big_monitor -d 1 2 3 4
        bspc monitor $small_monitor -d 5 6 7 8
        ;;
    SmallBigTV)
        xrandr --output $small_monitor --primary --mode 1360x768 --pos 0x312 --output $big_monitor --mode 1920x1080 --output $tv_monitor --mode 1280x720 --right-of $big_monitor 
        bspc monitor $small_monitor -d 1 2 3 4
        bspc monitor $tv_monitor -d 5 6 7 8
        bspc monitor $tv_monitor -d 9 10 11 12
        ;;
    BigTV)
        xrandr --output $small_monitor --same-as $big_monitor --output $big_monitor --mode 1920x1080 --output $tv_monitor --mode 1280x720 --right-of $big_monitor 
        bspc monitor $small_monitor -d 1 2 3 4
        bspc monitor $tv_monitor -d 5 6 7 8
        ;;
    Big)
        xrandr --output $small_monitor --same-as $big_monitor --primary --output $big_monitor --mode 1920x1080 --pos 1360x0 --output $tv_monitor --off
        bspc monitor $small_monitor -d 1 2 3 4 5 6 7 8
        ;;
    Small)
        xrandr --output $small_monitor  --primary --mode 1360x768 --pos 0x312 --output $big_monitor --off --output $tv_monitor --off
        bspc monitor $big_monitor -d 1 2 3 4 5 6 7 8
        ;;
    TV)
        xrandr --output $small_monitor --same-as $tv_monitor --output $big_monitor --off --output $tv_monitor --mode 1280x720
        bspc monitor $tv_monitor -d 1 2 3 4 5 6 7 8
        ;;
    *)
        echo "unknown argument"
esac


if [ -z "$1" ] && ! [ -e /tmp/active-monitor-mode ]; then
    bspc config pointer_follows_monitor true
    bspc monitor -f $big_monitor
    bspc config pointer_follows_monitor false
fi

# xrandr --output DisplayPort-0 --primary --mode 1920x1080 --output HDMI-A-0 --mode 1920x1080 --same-as DisplayPort-0
# xrandr --output DisplayPort-1 --mode 1360x768 --pos 0x312 --output DisplayPort-1-0 --mode 1920x1080 --primary --pos 1360x0 --output $tv_monitor --mode 1280x720 --pos 3282x0  
# xrandr --output DisplayPort-1 --mode 1360x768 --pos 0x312 --output DisplayPort-1-0 --mode 1920x1080 --pos 1360x0
