# echo "# this file is located in 'src/commands/autostart/scripts.sh'"
# echo "# code for 'archdots autostart scripts' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

if [ -z ${PREVENT_ALWAYS+x} ]; then
	all_always="$(archdots settings '.autostart.always[]' -r)"
	readarray -t all_always <<< $all_always

	for always_command in "${all_always[@]}"; do
		(echo "$always_command"|bash)||notify-send autostart "an error has ocurred with \"$always_command\""
	done
fi

all_programs="$(archdots settings '.autostart.programs[]' -r)"
readarray -t all_programs <<< $all_programs

for program in "${all_programs[@]}"; do
		unset program_arguments

		program_arguments=(${program[@]})

		program_path="${program_arguments[0]}"
		program_basename="$(basename "$program_path")"

		program_arguments=$(echo "${program_arguments[@]:1}")

		if [ -n "$program_arguments" ];then
				program_command="$program_path $program_arguments"
		else
				program_command="$program_path"
		fi

		if [ -n "${args[--restart]}" ];then
				echo "$program_command"
				pgrep -x "$program_basename"|xargs -i kill {};sleep 1 && $(eval "echo $program_command") &
		else
				pgrep -x "$program_basename" > /dev/null || $(eval "echo $program_command") &
		fi
done
