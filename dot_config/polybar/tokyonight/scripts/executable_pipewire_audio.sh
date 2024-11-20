#!/bin/sh

getDefaultSink() {
  defaultSink=$(wpctl status | awk 'c&&!--c;/Default Configured Devices:/{c=1}' | awk '{print $3}')
  # description=$(pactl list sinks | sed -n "/${defaultSink}/,/Description/s/^\s*Description: \(.*\)/\1/p")
  echo "${defaultSink}"
}

getDefaultSource() {
  defaultSource=$(wpctl status | awk 'c&&!--c;/Default Configured Devices:/{c=2}' | awk '{print $3}')
  # description=$(pactl list sources | sed -n "/${defaultSource}/,/Description/s/^\s*Description: \(.*\)/\1/p")
  echo "${defaultSource}"
}

update() {
  SINK=$(getDefaultSink)
  SOURCE=$(getDefaultSource)
  VOLUME=$(pamixer --get-volume-human --sink $SINK | sed 's/%//')
}

volume_print() {
  if [[ $VOLUME -le 0 ]]; then
    echo " Muted"
  elif [[ $VOLUME -lt 30 ]]; then
    echo " $VOLUME"
  elif [[ $VOLUME -lt 70 ]]; then
    echo " $VOLUME"
  else
    echo " $VOLUME"
  fi
}

listen() {
  update
  volume_print

  pactl subscribe | while read -r event; do
    if echo "$event" | grep -qv "Client" && ! (echo "$event" | rg -q 'remove|new'); then
      update
      volume_print
    fi
  done
}

update

case $1 in
"--up")
  pamixer --sink $SINK --increase 5 || amixer -q -D pulse sset Master 5%+
  ;;
"--down")
  pamixer --sink $SINK --decrease 5 || amixer -q -D pulse sset Master 5%+
  ;;
"--mute")
  pamixer --sink $SINK --toggle-mute || amixer -q -D pulse set Master toggle
  ;;
*)
  listen
  ;;
esac
