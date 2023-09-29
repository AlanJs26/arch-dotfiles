#!/usr/bin/env bash

# n=$(cat ~/.cache/dunst/notifications.txt|wc -l)
n=$($HOME/.config/eww/scripts/notification_logger.zsh normal)

if [ "$(dunstctl is-paused)" == "true" ]; then
	echo "󰪑" 
	return
fi

if [ "$n" != "0" ]; then
	echo "  $n"
else
	echo ""
fi
