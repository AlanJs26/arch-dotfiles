#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! $(yay -Qs amdgpu-pro-oglp) ]]; then
		echo notok
	fi
	exit
fi

(cd "$HOME/.local/share/chezmoi/archdots/public/amdgpu-pro-installer" && makepkg -s)
