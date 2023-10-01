#!/usr/bin/env bash


if [ "$1" = "check" ]; then
	if [ ! -f "$(which evrouter)" ]; then
		echo notok
	fi
	exit
fi

if [ ! -f "$(which evrouter)" ]; then
	(cd "$HOME/.local/share/chezmoi/archdots/public/evrouter" && makepkg --install)
else
	echo Alredy configured
fi



