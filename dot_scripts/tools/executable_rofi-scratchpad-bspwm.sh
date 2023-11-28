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
	name=$(xprop -id "$w" WM_CLASS 2>/dev/null | sed -r 's/.+ "(.+)"$/\1/')
	title=$(xprop -id "$w" WM_NAME 2>/dev/null | sed -r 's/.+ "(.+)"$/\1/')

	if [ -z "$title" ]; then
		continue
	fi
	name="$(parse_name "$name" "$title")"

	[ "$name" = "WM_CLASS" ] && echo "node $w" || echo -en "$name  \"$title\"\0icon\x1f$name\n"
done | rofi -dmenu -format  i -p 'Unhide: ')
if [ -n "$n" ]; then
	id=$(echo "$win" | sed -n "$((n+1))p")
	bspc node "$id" --flag hidden=off --focus
fi
