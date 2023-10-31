#!/bin/sh
#Focus windows by direction, works with multihead
#called like this in sxhkdrc:
#super +  {a,s,w,d}
#   focusmover {west,south,north,east} 

tree="$(bspc query -T -d focused)"
layout="$(echo "$tree"|jq .layout -r)"
child="$(echo "$tree"|jq .root.firstChild -r)"

DIR=$@
if [ "$layout" = "tiled" ] || ([ "$layout" = "monocle" ] && [ "$child" = "null" ]); then
    bspc query -N|xargs -I id -n 1 bspc node id -p cancel;\
    bspc config pointer_follows_monitor true
    bspc config pointer_follows_focus true
    if ! bspc node -f $DIR; then 
        bspc monitor -f $DIR
    fi
    bspc config pointer_follows_monitor false
    bspc config pointer_follows_focus false

elif [ "$layout" = "monocle" ]; then
    case $DIR in
        east|west)
            bspc monitor -f $DIR
            ;;
        south)
            bspc node -f "prev.local.!hidden.window"
            ;;
        north)
            bspc node -f "next.local.!hidden.window"
            ;;
    esac
fi

