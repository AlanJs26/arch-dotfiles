#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! -d "$HOME/.local/share/chezmoi/archdots/public/amdgpu-pro-installer/pkg" ]]; then
		echo notok
	fi
	exit
fi

(cd "$HOME/.local/share/chezmoi/archdots/public/amdgpu-pro-installer" && makepkg -s)
