#!/usr/bin/env sh

active_desktop="$(bspc query -D -d focused)"
bspc rule -a "*:$@:*" --one-shot desktop="$active_desktop" focus=off
$@
