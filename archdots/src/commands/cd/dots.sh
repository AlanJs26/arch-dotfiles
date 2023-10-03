#!/usr/bin/env sh

if [[ -n $CHEZMOI_NESTED ]]; then
	echo cannot create another nested shell. Please press Ctrl+D and run again
	exit
fi

echo you are inside a nested shell
export CHEZMOI_NESTED="y"
cd $HOME/.local/share/chezmoi
$SHELL
