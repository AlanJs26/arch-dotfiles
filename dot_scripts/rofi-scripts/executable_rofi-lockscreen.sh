#!/usr/bin/bash

mode="$(echo "enable
disable
lock" | rofi -dmenu -p 'lockscreen')"

case "$mode" in
enable)
  $HOME/.scripts/tools/lockscreen.sh start
  ;;
disable)
  $HOME/.scripts/tools/lockscreen.sh disable
  ;;
lock)
  $HOME/.scripts/tools/lockscreen.sh lock
  ;;
esac
