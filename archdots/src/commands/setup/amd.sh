#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! -f /etc/modprobe.d/amdgpu.conf ]]; then
		echo notok
	fi
	exit
fi

if [[ ! -f /etc/modprobe.d/amdgpu.conf ]]; then
	echo Adding amd radeon configuration to /etc/modprobe.d/
	cat "$HOME/.local/share/chezmoi/archdots/public/amdgpu.conf" | sudo dd of=/etc/modprobe.d/amdgpu.conf 
	cat "$HOME/.local/share/chezmoi/archdots/public/radeon.conf" | sudo dd of=/etc/modprobe.d/radeon.conf 

	cat "$HOME/.local/share/chezmoi/archdots/public/20-amdgpu.conf" | sudo dd of=/etc/X11/xorg.conf.d/20-amdgpu.conf 

	cat "$HOME/.local/share/chezmoi/archdots/public/mkinitcpio_amdgpu.conf" | sudo dd of=/etc/mkinitcpio.conf.d/mkinitcpio_amdgpu.conf 
	cat /etc/mkinitcpio.conf|rg --passthrough '^MODULES=.+' -r 'MODULES=(amdgpu radeon)'| sudo dd of=/etc/mkinitcpio.conf 

	sudo mkinitcpio -P
else
	echo Alredy configured
fi



