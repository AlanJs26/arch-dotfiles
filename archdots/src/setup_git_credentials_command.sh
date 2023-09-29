#!/usr/bin/env bash

useremail="$(git config --global --get user.email||echo '')"
username="$(git config --global --get user.name||echo '')"


if [ "$1" = "check" ]; then
	if [[ -z "$useremail" ]] || [[ -z "$username" ]]; then
		echo notok
	fi
	exit
fi

useremail=$(gum input --placeholder "Type user.email...")
echo "user.email: $useremail"
username=$(gum input --placeholder "Type user.name...")
echo "user.name: $username"

[ -n "$useremail" ]&&git config --global user.email "$useremail"||echo "Empty input. Did not change previous"
[ -n "$username" ]&&git config --global user.name "$username"||echo "Empty input. Did not change previous"



