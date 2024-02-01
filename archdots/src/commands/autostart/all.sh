# echo "# this file is located in 'src/commands/autostart/all.sh'"
# echo "# code for 'archdots autostart all' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

set -e

PREVENT_ALWAYS=1
all_always="$(archdots settings '.autostart.always[]' -r)"
readarray -t all_always <<< $all_always

for always_command in "${all_always[@]}"; do
	(echo "$always_command"|bash)||notify-send autostart "an error has ocurred with \"$always_command\""
done


archdots autostart scripts ${args[--restart]}
archdots autostart programs ${args[--restart]}
