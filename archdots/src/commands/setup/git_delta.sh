#!/usr/bin/env bash



if [ "$1" = "check" ]; then
	if [[ -z "$(cat ~/.gitconfig|grep 'pager = delta')" ]]; then
		echo notok
	fi
	exit
fi

if [[ -z "$(cat ~/.gitconfig|grep 'pager = delta')" ]]; then
	echo Appending git delta configuration to $HOME/.gitconfig
	cat "$HOME/.local/share/chezmoi/archdots/public/gitdelta_snippet.txt" >> $HOME/.gitconfig 
else
	echo Alredy configured
fi



