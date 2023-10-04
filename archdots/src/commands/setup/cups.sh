#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! $(systemctl status cups|rg '\(running\)') ]]; then
		echo notok
	fi
	exit
fi


echo Enabling cups service
sudo systemctl enable --now cups
echo Running HP setup
system-config-printer
