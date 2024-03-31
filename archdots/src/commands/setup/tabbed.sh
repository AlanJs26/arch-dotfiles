#!/usr/bin/env bash


if [ "$1" = "check" ]; then
	if [ ! -f "$(which tabbed 2> /dev/null)" ]; then
		echo notok
	fi
	exit
fi

(cd "$HOME/.local/share/chezmoi/archdots/public/tabbed" && make clean install)
