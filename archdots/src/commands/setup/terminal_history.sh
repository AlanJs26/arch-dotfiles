#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ -z "$(atuin status|rg 'Username: .{2,}')" ]]; then
		echo notok
	fi
	exit
fi

if gum confirm "Have you already registered to Atuin?"; then
	atuin login
else
	atuin register
fi
atuin import auto
atuin sync
