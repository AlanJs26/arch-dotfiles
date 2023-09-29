#!/bin/env bash


is_polybar_hidden=$(cat /tmp/is_polybar_hidden||echo 0)

polybarmonitors=$(pgrep polybar|xargs -i sh -c "xdotool search --pid {}|head -n1"|xargs -i xdotool getwindowname {}|cut -d"_" -f2)
IFS=$'\n' read -d '' -a polybarmonitors <<< $polybarmonitors

polybarpids=$(pgrep polybar)
IFS=$'\n' read -d '' -a polybarpids <<< $polybarpids

monitorid="$(bspc query -M -m $1)"
mode="$(bspc query -T -m $monitorid|jq .root.client.state -r)"

content=""

# print > /tmp/is_polybar_hidden
if [ $mode != "fullscreen" ]; then
	for ((i=0; i<${#polybarmonitors[@]}; i++)); do
			monitor="${polybarmonitors[$i]}"
			current_monitorid="$(bspc query -M -m $monitor)"

			if [ $monitorid = $current_monitorid ]; then
					monitorpid="${polybarpids[$i]}"

					echo $monitor
					if [ "${is_polybar_hidden[$i+1]}" = "0" ] || [ $(bspc config -m $monitorid top_padding) != "0" ]; then
						polybar-msg -p $monitorpid cmd hide&&bspc config -m $monitorid top_padding 0
						content="${content}1"
					else
						polybar-msg -p $monitorpid cmd show
						content="${content}0"
					fi
			else
				if [ $(bspc config -m $current_monitorid top_padding) != "0" ]; then
						content="${content}1"
				else
						content="${content}0"
				fi
			fi
	done
	echo $content > /tmp/is_polybar_hidden
fi




