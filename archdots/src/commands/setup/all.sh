#!/usr/bin/env bash

commands=$(dir $HOME/.local/share/chezmoi/archdots/src/commands/setup/* -1|xargs -i basename {} .sh|rg -v '^all')


if [[ ${args[--status]} -eq 1 ]]; then

	for item in ${commands[@]}; do

		if [[ "$($HOME/.local/share/chezmoi/archdots/src/commands/setup/${item}.sh check)" = "notok" ]]; then
			gum style --foreground 1 $item
		else
			gum style --foreground 2 $item
		fi

	done

	exit
fi

for item in ${commands[@]}; do

	if [[ "$($HOME/.local/share/chezmoi/archdots/src/commands/setup/${item}.sh check)" = "notok" ]] || [[ ${args[--force]} -eq 1 ]]; then

		gum style --foreground 212 --padding "1 4" --border rounded "Setup $item"
		source $HOME/.local/share/chezmoi/archdots/src/commands/setup/${item}.sh
	fi
done


