
if [ -z "${args[config]}" ] && [ -z "${args[--current]}" ]; then
	archdots alternate_config --help
	exit
fi

if [ -n "${args[--current]}" ]; then
	cat /tmp/current_alternate_config 2> /dev/null||echo 
	exit
fi

check_alternate_config_exists () {
	archdots settings ".alternate_configs|map(.name == \"$1\")|any" 
}

if [ "$(check_alternate_config_exists "${args[config]}")" = "true" ]; then
	echo ${args[config]} > /tmp/current_alternate_config
elif [ "${args[config]}" = "auto" ]; then

	all_scripts="$(archdots settings '.alternate_configs[].detect_script'  -r)"
	readarray -t all_scripts <<< $all_scripts

	i=-1
	for script in "${all_scripts[@]}"; do
		i=$((i+1))

		if [ -n "$($script)" ]; then
			detected_config="$(archdots settings ".alternate_configs[$i].name" -r)"
			echo $detected_config
			echo $detected_config > /tmp/current_alternate_config
			exit
		fi
	done

	echo "Could not detect any of the registered alternate configs"
else
	echo "This config \"${args[config]}\" does not exist"
fi
