#!/usr/bin/bash

mode="$(echo "enable
disable
lock"|rofi -dmenu -p 'lockscreen')"

case "$mode" in
    enable)
        $HOME/.local/bin/lockscreen.sh start
    ;;
    disable)
        $HOME/.local/bin/lockscreen.sh disable
    ;;
    lock)
        $HOME/.local/bin/lockscreen.sh lock
    ;;
esac

