#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ -z "$(groups|grep docker)" ]]; then
		echo notok
	fi
	exit
fi

if [[ -z "$(groups|grep docker)" ]]; then
	echo -e "copy the following commands on your current shell\n"
	echo sudo groupadd docker 
	echo sudo gpasswd -a $USER docker
	echo sudo usermod -aG docker $USER
	echo newgrp docker
else
	echo Alredy configured
fi



