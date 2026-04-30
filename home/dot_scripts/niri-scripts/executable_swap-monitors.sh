#!/usr/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || ! (echo "$1" | grep -q 'left\|right'); then
  cat <<EOF
Swaps current monitor with the left/right monitor

Usage:
    swap-monitors.sh left|right
EOF
  exit 0
fi

dir_main="left"
dir_oposite="right"

if [[ "$1" == "right" ]]; then
  dir_main="right"
  dir_oposite="left"
fi

niri msg action "focus-monitor-$dir_main"
niri msg action "move-workspace-to-monitor-$dir_oposite"
niri msg action focus-workspace-up
niri msg action "move-workspace-to-monitor-$dir_main"
