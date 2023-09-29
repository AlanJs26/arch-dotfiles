# echo "# this file is located in 'src/setup_monitors_command.sh'"
# echo "# code for 'archdots setup monitors' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

apps=$HOME/.config/bspwm/apps.json

available_monitors=($(xrandr -q|rg connected|awk '{ print $1 }'))

primary_monitor="$(gum choose --header="Primary Monitor $(jq .monitors.primary $apps)" "${available_monitors[@]}")"
secundary_monitor="$(gum choose --header="Secundary Monitor $(jq .monitors.secundary $apps)" "${available_monitors[@]}")"
tv_monitor="$(gum choose --header="TV $(jq .monitors.tv $apps)" "${available_monitors[@]}")"

result="$(cat $apps|jq\
	--arg primary $primary_monitor\
	--arg secundary $secundary_monitor\
	--arg tv $tv_monitor\
	'.monitors.primary = $primary | .monitors.secundary = $secundary | .monitors.tv = $tv')" 

echo "$result"|jq '.' > $apps	

# for item in ${available_monitors[@]}; do
# 	echo $item
# done
