#!/usr/bin/env bash


if [ "$1" = "check" ]; then
	if [ ! -f "$(which downgrade 2> /dev/null)" ]; then
		echo notok
	fi
	exit
fi

mkdir -p $HOME/.local/share
mkdir -p $HOME/.local/bin

git clone https://github.com/archlinux-downgrade/downgrade $HOME/.local/share/downgrade
chmod +x $HOME/.local/share/downgrade/bin/*
ln -s $HOME/.local/share/downgrade/bin/downgrade $HOME/.local/bin/downgrade 
