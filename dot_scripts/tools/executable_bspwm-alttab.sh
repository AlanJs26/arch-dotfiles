#!/usr/bin/env bash
# win=$(bspc query -N -n .window)
win=$(bspc wm -d|jq '.focusHistory| map(select(.nodeId != 0)) | [.[].nodeId].[]'| tac | awk '!a[$0]++')

if [ $(echo "$win"|wc -l) -le 2 ]; then
	bspc config pointer_follows_focus true
	bspc node next --focus
	bspc config pointer_follows_focus false
	exit
fi

xdotool search --sync --syncsleep 50 --limit 1 --class Rofi keyup --delay 0 Tab key --delay 0 Tab&

small_monitor="$(bspmonitors query --monitor secundary)"
big_monitor="$(bspmonitors query --monitor primary)"
tv_monitor="$(bspmonitors query --monitor tv)"

focused_monitor="$(bspc query -M --names -m focused)"

if [ "$focused_monitor" = "$big_monitor" ]; then
	xdotool mousemove $((1360+(1920)/2)) $((1080/2)) sleep 0.1 mousemove restore&
elif [ "$focused_monitor" = "$small_monitor" ]; then
	xdotool mousemove $((1360/2)) $((312+(768/2))) sleep 0.1 mousemove restore&
fi

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

n=$(for w in $win; do

	# name=$(xprop -id "$w" WM_CLASS 2>/dev/null | rg '"(.+?)"' -or '$1'|head -n1 )
	instance_name=$(xprop -id "$w" WM_CLASS 2>/dev/null |rg "^WM_CLASS.+?\"(.+?)\".*" -r '$1')
	title=$(xprop -id "$w" WM_NAME 2>/dev/null | rg '"(.+?)"' -or '$1'|head -n1 )
	if [ -z "$title" ]; then
		continue
	fi
	instance_name="$(parse_name "$instance_name" "$title")"
	[ "$instance_name" = "WM_CLASS" ] && echo "node $w" || echo -en "$instance_name  \"$title\"\0icon\x1f$instance_name\n"
done | rofi -dmenu -format  i -p 'Windows: '\
		-theme "~/.config/rofi/tokyonight/rofi-alttab.rasi"\
    -kb-cancel "Alt+Escape,Escape" \
    -kb-accept-entry "!Alt-Tab,!Alt-Alt_L,!Alt_L,Return"\
    -kb-row-down "Alt+Tab,Alt+Down" \
    -kb-row-up "Alt+ISO_Left_Tab,Alt+Up"\
		-selected-row 1
# xdotool keyup Tab&&\
# xdotool keydown Tab
)

# wait "$n"

if [ -n "$n" ]; then
	id=$(echo "$win" | sed -n "$((n+1))p")
	bspc config pointer_follows_focus true
	bspc node "$id" --flag hidden=off --focus
	bspc config pointer_follows_focus false
fi

