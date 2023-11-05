#!/usr/bin/env bash

# n=$(cat ~/.cache/dunst/notifications.txt|wc -l)
n="$($HOME/.config/eww/scripts/notification_logger.zsh normal)"
n_pending="$($HOME/.config/eww/scripts/notification_logger.zsh pending)"

if [ "$(dunstctl is-paused)" == "true" ]; then
	echo "󰪑" 
	return
fi

if [[ "$n_pending" = "0" ]] && [[ "$n" != "0" ]]; then
	echo ""
elif [ "$n_pending" != "0" ]; then
	echo "  $n_pending"
else
	echo ""
fi
