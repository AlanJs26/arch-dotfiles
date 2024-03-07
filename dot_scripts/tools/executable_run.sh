#!/usr/bin/bash

arg=$1
ext=$(echo $arg | rg '\..+$' -o)

if [[ $arg =~ 'xdg-open' ]]; then
    arg=${1:10:-1}
    ext=$(echo $arg | rg "\..+$" -o)
fi

mime="$(file -b "$arg")"

zoxide add "$(dirname "$arg")"

if [[ $mime =~ "image" ]]; then
    feh "$arg" --class "__float__" --scale-down
elif [[ $mime =~ "PowerPoint" ]]; then
    zaread "$arg"
elif [[ $mime =~ "ASCII" ]]; then
    kitty nvim "$arg"
elif [ -n "$(echo "$mime"|grep -i "document")" ]; then
    zaread "$arg"
else
    xdg-open "$arg"
fi
