#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! -f $HOME/.oh-my-zsh/completions/_archdots ]]; then
		echo notok
	fi
	exit
fi

echo Adding archdots completions to zsh
mkdir -p $HOME/.oh-my-zsh/completions
cp "$HOME/.local/share/chezmoi/archdots/public/_archdots" "$HOME/.oh-my-zsh/completions/"



