#!/usr/bin/env sh

if [[ -n $PACDEF_NESTED ]]; then
	echo cannot create another nested shell. Please press Ctrl+D and run again
	exit
fi

echo you are inside a nested shell
export PACDEF_NESTED="y"
cd $HOME/.config/pacdef
$SHELL
