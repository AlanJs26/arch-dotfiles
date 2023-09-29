#!/bin/bash

declare -i sinks=(`pacmd list-sinks | sed -n -e 's/\**[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p'`)
declare -i sinks_count=${#sinks[*]}
declare -i active_sink_index=`pacmd list-sinks | sed -n -e 's/\*[[:space:]]index:[[:space:]]\([[:digit:]]\)/\1/p'`
declare -i next_sink_index=${sinks[0]}

#find the next sink (not always the next index number)
declare -i ord=0
while [ $ord -lt $sinks_count ];
do
if [ ${sinks[$ord]} -gt $active_sink_index ] ; then
    next_sink_index=${sinks[$ord]}
    break
fi
let ord++
done

if [ "$1" != "get_default" ]; then
    #change the default sink
    pacmd "set-default-sink ${next_sink_index}"

    #move all inputs to the new sink
    for app in $(pacmd list-sink-inputs | sed -n -e 's/index:[[:space:]]\([[:digit:]]\)/\1/p');
    do
    pacmd "move-sink-input $app $next_sink_index"
    done
fi

#display notification
declare -i ndx=0
pacmd list-sinks | sed -n -e 's/device.description[[:space:]]=[[:space:]]"\(.*\)"/\1/p' | while read line; do
    if [ $(( $ord % $sinks_count )) -eq $ndx ] ; then

        if [ "$1" != "get_default" ]; then
            notify-send -a bspwm -i "/usr/share/icons/Tela-circle-dark/16/actions/audio-ready.svg" "Sound output switched to" "$line" -u low
        else
            # echo "- $line" > /tmp/active-sink
            echo "- $line"
        fi
        exit
    fi
    let ndx++
done;
