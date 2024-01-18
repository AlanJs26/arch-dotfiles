# echo "# this file is located in 'src/commands/autostart/all.sh'"
# echo "# code for 'archdots autostart all' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args


all_alwayss="$(archdots settings '.autostart.always[]' -r)"
readarray -t all_alwayss <<< $all_alwayss

for always_command in "${all_alwayss[@]}"; do
		$(eval "echo $always_command")
done


archdots autostart scripts ${args[--restart]}
archdots autostart programs ${args[--restart]}
