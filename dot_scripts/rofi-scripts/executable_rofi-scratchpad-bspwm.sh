#!/usr/bin/env bash

function parse_name() {
	name="$1"
	title="$2"
	case "$title" in
		floatkitty) 
			echo kitty 
			;;
		floatkittynvim)
			echo nvim
			;;
		AudioRelay)
			echo audiorelay
			;;
		Qalculate!)
			echo qalculate
			;;
		*)
			echo "$name"
			;;
	esac
}

win=$(bspc query -N -n .hidden.window)
n=$(for w in $win; do
	# name=$(xprop -id "$w" WM_CLASS 2>/dev/null | sed -r 's/.+ "(.+)"$/\1/')
	title=$(xprop -id "$w" WM_NAME 2>/dev/null | sed -r 's/.+ "(.+)"$/\1/')
	instance_name=$(xprop -id "$w" WM_CLASS 2>/dev/null |rg "^WM_CLASS.+?\"(.+?)\".*" -r '$1')

	if [ -z "$title" ]; then
		continue
	fi
	instance_name="$(parse_name "$instance_name" "$title")"

	[ "$instance_name" = "WM_CLASS" ] && echo "node $w" || echo -en "$instance_name  \"$title\"\0icon\x1f$instance_name\n"
done | rofi -dmenu -format  i -p 'Unhide: ')
if [ -n "$n" ]; then
	id=$(echo "$win" | sed -n "$((n+1))p")
	bspc node "$id" --flag hidden=off --focus
fi
