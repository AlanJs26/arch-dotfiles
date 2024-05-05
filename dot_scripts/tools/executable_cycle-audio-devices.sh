#!/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<EOF
Enable next audio device or port

Usage:
    cycle-audio-device.sh [--active-device|--active-port|--port|--device] [--id]

    --active-device (optional) 
            print active audio device
    --active-port (optional) 
            print active port
    --port (optional) 
            cycles against active device's ports 
    --device (default) 
            cycles against detected audio devices 

    --id (optional) 
            print active port or audio device id instead of name 
EOF
    exit 0
fi

get_sink_by_index () {
    pacmd list-sinks| rg --multiline-dotall -U --pcre2 -o "index: $1.+?(?=index:|\Z)"   
}

declare -i sinks=(`pacmd list-sinks | rg 'index: (\d+)' -o -r '$1'`)
declare -i sinks_count=${#sinks[*]}
declare -i active_sink_index=`pacmd list-sinks | rg '\* index: (\d+)' -o -r '$1' -m 1`
declare -i next_sink_index=${sinks[0]}

for sink_index in ${sinks[@]}; do
    status="$(get_sink_by_index $sink_index|rg 'state: (.+)' -or '$1')"
    if [ "$status" = "RUNNING" ]; then
        active_sink_index=$sink_index
        break
    fi
done

#find the next sink (not always the next index number)
if [ $((active_sink_index+1)) -eq $sinks_count ]; then
    next_sink_index=0
else
    next_sink_index=$((active_sink_index+1))
fi


active_port="$(get_sink_by_index $active_sink_index|rg 'active port: <(.+)>' -o -r '$1')"

case "$1" in
    --active-device)
        if [ "$2" = "--id" ]; then
            echo $active_sink_index
        else
            get_sink_by_index $active_sink_index|rg 'device\.description = "(.+)"' -o -r '$1'
        fi
    ;;
    --active-port)
        echo $active_port
    ;;
    --port)
        ports="$(get_sink_by_index $active_sink_index|rg -o '^\s*(.+-output.+?):' -r '$1')"

        next_ports="$(cat <<< "$ports"| rg --multiline-dotall -U --pcre2 -o "(?<=$active_port).+"|awk 'NR > 0')"

        if (cat <<< "$next_ports"|rg -q '\S'); then
            next_port="$(echo "$next_ports"|head -n 1)"
        else
            next_port="$(echo "$ports"|head -n 1)"
        fi

        pacmd set-sink-port $active_sink_index "$next_port"

        notify-send -a bspwm -i "/usr/share/icons/Tela-circle-dark/16/actions/audio-ready.svg" "Port switched to" "$next_port" -u low
    ;;
    --device|*)

        #change the default sink
        pacmd set-default-sink ${next_sink_index}

        #move all inputs to the new sink
        sink_inputs=$(pacmd list-sink-inputs | rg -o 'index: (\d+)' -r '$1')

        for index in ${sink_inputs[@]}; do
            pacmd move-sink-input $index $next_sink_index
        done

        sink_name="$(get_sink_by_index $next_sink_index|rg 'device\.description = "(.+)"' -o -r '$1')"

        notify-send -a bspwm -i "/usr/share/icons/Tela-circle-dark/16/actions/audio-ready.svg" "Sound output switched to" "$sink_name" -u low
    ;;
esac
