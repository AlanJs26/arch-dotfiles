#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! $(rclone listremotes 2> /dev/null|rg drive) ]]; then
		echo notok
	fi
	exit
fi

rclone config

echo -e "\nProbably you need to modify ~/.scripts/tools/rclone-sync.sh with the correct paths" 



