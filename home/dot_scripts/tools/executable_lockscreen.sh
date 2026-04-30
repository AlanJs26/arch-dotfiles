#!/bin/bash

timeout=1200
notify=$((timeout / 30))
# display=$(systemd-escape -- "$DISPLAY")

configure() {
  xset s $((timeout - notify)) $notify
  xset dpms $((timeout * 2)) $((timeout * 22 / 10)) $((timeout * 24 / 10))
}
unconfigure() {
  xset s 0
  xset dpms 0 0 0
  killall xss-lock
}

case "$1" in
start)
  me="$(readlink -f "$0")"

  configure
  exec xss-lock --notifier="$me notify" lock.sh

  notify-send "Suspend timer" "Enabled (after $((timeout / 60)) min)"
  ;;
lock)
  echo "lock: lock screen (idle: $(xprintidle))"
  # Something may have mendled with screensaver settings
  configure
  # First, pause any music player
  playerctl -a pause
  # Then, lock screen
  # i3lock -n -e -i $HOME/.cache/awesome/current-wallpaper-${display}.png -t -f

  betterlockscreen -l blur
  echo "lock: unlock screen"
  ;;
disable)
  unconfigure
  notify-send "Suspend timer" "Disabled"
  ;;
esac
