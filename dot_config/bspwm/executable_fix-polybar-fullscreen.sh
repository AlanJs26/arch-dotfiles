#!/bin/env bash



bspc subscribe node_state node_focus desktop_focus | while read -a msg ; do

    polybar-msg action bspwm-monocle hook 0

    is_polybar_hidden=$(cat /tmp/is_polybar_hidden||echo 0)

    polybarmonitors=$(pgrep polybar|xargs -i sh -c "xdotool search --pid {}|head -n1"|xargs -i xdotool getwindowname {}|cut -d"_" -f2)
    IFS=$'\n' read -d '' -a polybarmonitors <<< $polybarmonitors

    polybarpids=$(pgrep polybar)
    IFS=$'\n' read -d '' -a polybarpids <<< $polybarpids

    event="${msg[0]}"
    mode="${msg[4]}"
    state="${msg[5]}"
    monitorid="${msg[1]}"
    monitorname="$(bspc query -M -m $monitorid --names)"

    if [ $event = "node_focus" ]; then
        if [ -z $(bspc query -N -n .focused.fullscreen) ] && [ $is_polybar_hidden = "0" ]; then
            for ((i=0; i<${#polybarmonitors[@]}; i++)); do
                monitor="${polybarmonitors[$i]}"
                if [ $monitorname = $monitor ]; then
                    monitorpid="${polybarpids[$i]}"

                    polybar-msg -p $monitorpid cmd show
                fi
            done
        fi
    else if [ $mode = "fullscreen" ] && [ $is_polybar_hidden = "0" ]; then
            for ((i=0; i<${#polybarmonitors[@]}; i++)); do
                monitor="${polybarmonitors[$i]}"
                if [ $monitorname = $monitor ]; then
                    monitorpid="${polybarpids[$i]}"

                    if [ $state = "on" ]; then
                      polybar-msg -p $monitorpid cmd hide&&bspc config -m $monitorid top_padding 0
                    else
                      polybar-msg -p $monitorpid cmd show
                    fi
                fi
            done
        fi
    fi

done



