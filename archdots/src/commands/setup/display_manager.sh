#!/usr/bin/env bash


if [ "$1" = "check" ]; then
	if [ ! -f "/usr/share/pixmaps/lightdm_background.png" ]; then
		echo notok
	fi
	exit
fi

sudo mkdir -p /usr/share/pixmaps/
sudo mkdir -p /etc/lightdm
sudo cp $HOME/.local/share/chezmoi/archdots/public/lightdm_background.png /usr/share/pixmaps/
sudo cp $HOME/.local/share/chezmoi/archdots/public/lightdm_profile.png /usr/share/pixmaps/

sudo cp $HOME/.local/share/chezmoi/archdots/public/lightdm.conf /etc/lightdm
sudo cp $HOME/.local/share/chezmoi/archdots/public/lightdm-gtk-greeter.conf /etc/lightdm


