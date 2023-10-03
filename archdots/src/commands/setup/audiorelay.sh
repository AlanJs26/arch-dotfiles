#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! $(cat /etc/pulse/default.pa|rg 'Virtual-Mic') ]]; then
		echo notok
	fi
	exit
fi


if [[ ! $(cat /etc/pulse/default.pa|rg 'Virtual-Mic') ]]; then
	sudo cat "$HOME/.local/share/chezmoi/archdots/public/audiorelay-devices.txt" >> /etc/pulse/default.pa 
else
	echo Already configured
fi
