

all_monitors="$(xrandr -q|grep '\bconnected'|awk '{ print $1 }')"
readarray -t all_monitors <<< $all_monitors
prev_item="${all_monitors[0]}"

xrandr_command="xrandr --output $prev_item --auto --primary"
bspc_command="bspc monitor $prev_item -d 1 2 3 4 5"
id=5

for item in ${all_monitors[@]}; do
    if [[ "$item" != "$prev_item" ]]; then
        xrandr_command="$xrandr_command --output $item --auto --right-of $prev_item"

        bspc_command="$bspc_command;bspc monitor $item -d $((id+1)) $((id+2)) $((id+3)) $((id+4)) $((id+5))"
        id=$((id+5))

        prev_item="$item"
    fi
done

eval $xrandr_command
eval $bspc_command
