# echo "# this file is located in 'src/commands/settings.sh'"
# echo "# code for 'archdots settings' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

current_config="$(archdots alternate_config --current)"

if [ -n "$current_config" ]; then
	merged_settings="$(jq -s '.[0] * .[1]' $BSPSETTINGS "$SCRIPTS/$current_config.json")"
else
	merged_settings="$(cat $BSPSETTINGS)"
fi

if [ -z "${args[jqquery]}" ]; then
	cat <<< $merged_settings| jq .
elif [ -n "${args[--raw]}" ]; then
	cat <<< $merged_settings | jq "${args[jqquery]}" -r 
else
	cat <<< $merged_settings | jq "${args[jqquery]}" 
fi

#ala
