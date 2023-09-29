
group="${args[group]}"

if [[ ${args[--list]} -eq 1 ]]; then
	pacdef group list
elif [[ -n $group ]]; then
	if [[ -n "$(pacdef group list|grep -w $group)" ]];then
		cd "$HOME/.config/pacdef/groups"
		$EDITOR "$HOME/.config/pacdef/groups/${args[group]}"
	else
		gum style --foreground="1" "invalid group: '$group'"
		echo -e "\nvalid groups:"
		pacdef group list

	fi
else
	cd "$HOME/.config/pacdef/groups"
	$EDITOR "$HOME/.config/pacdef/groups"
fi
