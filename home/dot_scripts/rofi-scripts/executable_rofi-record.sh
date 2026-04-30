#!/usr/bin/bash

source ~/.env.sh

# Stop recording
if pgrep wf-recorder >/dev/null; then
  $TOOLS/record.sh
  exit
fi

mode="$(echo 'Region (No Sound)
Screen (No Sound)
Screen' | rofi -dmenu -p 'Record')"

ROFI_SCRIPTS=$SCRIPTS/rofi-scripts

case "$mode" in
"--list") ;;
"Region (No Sound)")
  $TOOLS/record.sh
  ;;
"Screen (No Sound)")
  $TOOLS/record.sh --fullscreen
  ;;
"Screen")
  $TOOLS/record.sh --fullscreen-sound
  ;;
*)
  echo "unknown argument"
  ;;
esac
