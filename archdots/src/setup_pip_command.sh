#!/usr/bin/env bash



if [ "$1" = "check" ]; then
	if [[ -z "$(cat ~/.config/pip/pip.conf|grep 'break-system-packages')" ]]; then
		echo notok
	fi
	exit
fi

if [[ -z "$(cat ~/.config/pip/pip.conf|grep 'break-system-packages')" ]]; then
	echo "Appending 'break-system-packages = true' to pip config in ~/.config/pip/pip.conf"
	mkdir -p $HOME/.config/pip
	cat "$(dirname $0)/public/pipconf_snippet.txt" >> $HOME/.config/pip/pip.conf 
else
	echo Alredy configured
fi



