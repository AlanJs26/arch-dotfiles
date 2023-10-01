#!/usr/bin/env bash

commands=$(ls $HOME/.local/share/chezmoi/archdots/src/setup_* -1|xargs -i basename {}|rg -o 'setup_(.+)_' -r '$1'|rg -v all)


if [[ ${args[--status]} -eq 1 ]]; then

	for item in ${commands[@]}; do

		if [[ "$($HOME/.local/share/chezmoi/archdots/src/setup_${item}_command.sh check)" = "notok" ]]; then
			gum style --foreground 1 $item
		else
			gum style --foreground 2 $item
		fi

	done

	exit
fi

for item in ${commands[@]}; do

	if [[ "$($HOME/.local/share/chezmoi/archdots/src/setup_${item}_command.sh check)" = "notok" ]] || [[ ${args[--force]} -eq 1 ]]; then

		gum style --foreground 212 --padding "1 4" --border rounded "Setup $item"
		source $HOME/.local/share/chezmoi/archdots/src/setup_${item}_command.sh
	fi
done


