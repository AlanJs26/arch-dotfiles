#!/usr/bin/env bash


if [ "$1" = "check" ]; then
	if [[ ! -d "$HOME/.config/nvim" ]]; then
		echo notok
	fi
	exit
fi

if [[ ! -d "$HOME/.config/nvim" ]]; then
	echo cloning nvim repo
	git clone "git@github.com:AlanJs26/nvim_config.git"
else
	echo Alredy configured
fi



