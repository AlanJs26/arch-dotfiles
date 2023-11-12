#!/bin/sh
#Focus windows by direction, works with multihead
#called like this in sxhkdrc:
#super +  {a,s,w,d}
#   focusmover {west,south,north,east} 

tree="$(bspc query -T -d focused)"
layout="$(echo "$tree"|jq .layout -r)"
child="$(echo "$tree"|jq .root.firstChild -r)"
node_state="$(bspc query -T -n focused|jq '.client.state' -r)"

bspc config pointer_follows_monitor true
bspc config pointer_follows_focus true
DIR=$@

node_dir="$(bspc query -N -n "$DIR.local.!hidden.!floating.window")"

if [ "$DIR" = "east" ] || [ "$DIR" = "north" ]; then
    next_prev="next"
elif [ "$DIR" = "west" ] || [ "$DIR" = "south" ]; then
    next_prev="prev"
fi

function focus_node() {
    target_node="$1"
    bspc node $target_node --focus
    # For some reason, bspwm fails in changing focus between floating and tiled nodes.
    # As a quickfix, retry 3 times until it succeeds. 
    count=1
    while [ "$(bspc query -N -n focused)" != "$target_node" ] && [ $count -le 3 ]; do
        bspc node $target_node --focus
        count=$((count+1))
    done
}

bspc query -N -n ".local.window"|xargs -I id -n 1 bspc node id -p cancel
if [ "$node_state" = "floating" ];then
    case $DIR in
        south|north)
            target_node="$(bspc query -N -n "next.local.!hidden.!floating.window")"
            focus_node "$target_node"
            ;;
        east|west)
            if ! bspc node -f "$DIR.local.!hidden.floating.window"; then
                bspc monitor -f $DIR
            fi
            ;;
    esac
elif [ "$layout" = "monocle" ] || [ -z "$node_dir" ] && [ $(echo "$DIR"|rg "south|north") ]; then
    case $DIR in
        east|west)
            bspc monitor -f $DIR
            ;;
        south|north)
            if [ "$layout" != "monocle" ] || [ "$(bspc query -N -n ".local.!hidden.!floating.window"|wc -l)" = "1" ]; then
                if ! bspc node -f "$next_prev.local.!hidden.floating.window"; then 
                    bspc node -f "$next_prev.local.!hidden.!floating.window"
                fi
            else
                bspc node -f "$next_prev.local.!hidden.!floating.window"
            fi
            ;;
    esac

elif [ "$layout" = "tiled" ] || ([ "$layout" = "monocle" ] && [ "$child" = "null" ]); then
    if [ -z "$node_dir" ] || ! bspc node $node_dir --focus; then 
        bspc monitor -f $DIR
    else
        focus_node "$node_dir"
    fi
fi
bspc config pointer_follows_monitor false
bspc config pointer_follows_focus false

