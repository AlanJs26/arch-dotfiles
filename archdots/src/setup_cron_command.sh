#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! $(crontab -l|rg rclone-sync) ]] || [[ ! $(ls /usr/lib/systemd/system|rg cronie) ]]; then
		echo notok
	fi
	exit
fi


echo Adding cron entries
crontab "$(dirname $0)/public/cron_rclone.txt"
echo Enabling cronie service
sudo systemctl enable cronie
