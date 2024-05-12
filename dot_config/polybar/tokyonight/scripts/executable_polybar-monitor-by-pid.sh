#!/bin/env bash


polybarmonitors=$(pgrep polybar|xargs -i sh -c "xdotool search --pid {}|head -n1"|xargs -i xdotool getwindowname {}|cut -d"_" -f2)
IFS=$'\n' read -d '' -a polybarmonitors <<< $polybarmonitors

polybarpids=$(pgrep polybar)
IFS=$'\n' read -d '' -a polybarpids <<< $polybarpids

monitorids="$(bspc query -M)"
IFS=$'\n' read -d '' -a monitorids <<< $monitorids

focused_monitorid="$(bspc query -M -m)"

for ((j=0; j<${#monitorids[@]}; j++)); do
	monitorid="${monitorids[$j]}"

	for ((i=0; i<${#polybarmonitors[@]}; i++)); do
			polybarmonitor="${polybarmonitors[$i]}"
			polybarmonitor_id="$(bspc query -M -m $polybarmonitor)"

			monitorpid="${polybarpids[$i]}"

			if [ $monitorid = $polybarmonitor_id ] && [ $monitorpid = $1 ]; then

				echo $polybarmonitor_id
				exit
			fi
	done
done




