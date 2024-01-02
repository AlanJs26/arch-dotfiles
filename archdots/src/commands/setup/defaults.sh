#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	exit
fi

gsettings set org.cinnamon.desktop.default-applications.terminal exec $(bsplaunch --query terminal)

