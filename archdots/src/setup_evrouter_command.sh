#!/usr/bin/env bash


if [ "$1" = "check" ]; then

	if [ ! -d "$(dirname $0)/public/evrouter/pkg" ]; then
		echo notok
	fi
	exit
fi

if [ ! -d "$(dirname $0)/public/evrouter/pkg" ]; then
	(cd "$(dirname $0)/public/evrouter" && makepkg --install)
else
	echo Alredy configured
fi



