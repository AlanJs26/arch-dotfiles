#!/usr/bin/env bash


if [ "$1" = "check" ]; then
	if [ ! -f "$(which yay)" ]; then
		echo notok
	fi
	exit
fi

(git clone https://aur.archlinux.org/yay.git /tmp/yay && cd /tmp/yay && makepkg -si)

