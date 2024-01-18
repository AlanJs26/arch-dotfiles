# echo "# this file is located in 'src/commands/autostart/scripts.sh'"
# echo "# code for 'archdots autostart scripts' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

all_scripts="$(archdots settings '.autostart.scripts[]' -r)"
readarray -t all_scripts <<< $all_scripts

for script in "${all_scripts[@]}"; do
		unset script_arguments

		script_arguments=(${script[@]})

		script_path="${script_arguments[0]}"
		script_basename="$(basename "$script_path")"

		script_arguments=$(echo "${script_arguments[@]:1}")

		if [ -n "$script_arguments" ];then
				script_command="$script_path $script_arguments"
		else
				script_command="$script_path"
		fi

		if [ -n "${args[--restart]}" ];then
				echo "$script_command"
				pgrep -f "$script_basename"|xargs -i kill {};sleep 1 && bash "$(eval "echo $script_command")" &
		else
				pgrep -f "$script_basename" > /dev/null || bash "$(eval "echo $script_command")" &
		fi
done
