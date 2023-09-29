#!/usr/bin/env bash



if [ "$1" = "check" ]; then
	if [[ -z "$(cat ~/.gitconfig|rg 'pager = delta')" ]]; then
		echo notok
	fi
	exit
fi

if [[ -z "$(cat ~/.gitconfig|rg 'pager = delta')" ]]; then
	echo Appending git delta configuration to $HOME/.gitconfig
	cat "$(dirname $0)/src/gitdelta_snippet.txt" >> $HOME/.gitconfig 
else
	echo Alredy configured
fi



