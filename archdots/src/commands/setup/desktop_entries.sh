#!/usr/bin/env bash


if [ "$1" = "check" ]; then
	if [ ! -f "/usr/share/xsessions/bspwm.desktop" ] || [ ! -f "/usr/share/wayland-sessions/hyprland.desktop" ]; then
		echo notok
	fi
	exit
fi

sudo mkdir -p /usr/share/wayland-sessions
sudo mkdir -p /usr/share/xsessions
sudo cp $HOME/.local/share/chezmoi/archdots/public/hyprland.desktop /usr/share/wayland-sessions
sudo cp $HOME/.local/share/chezmoi/archdots/public/bspwm.desktop /usr/share/xsessions


