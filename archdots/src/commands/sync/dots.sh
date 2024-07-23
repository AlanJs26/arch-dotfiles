#!/usr/bin/bash

cd ~/.local/share/chezmoi

add_settings_folders() {
	chezmoi_folders=($(archdots settings '.chezmoi[]' -r))
	n_folders=${#chezmoi_folders[@]}

	function add_chezmoi_folders() {
		i=0
		for folder in ${chezmoi_folders[@]}; do
			LC_NUMERIC=C printf "%.2f%% -- %s\n" "$progress" "$folder" 
			i=$((i+1))
			progress=$(bc -l <<< "100/$n_folders*$i")

			eval "expanded_folder=($folder)"
			expanded_folder="$(readlink -f $expanded_folder)"

			chezmoi add $expanded_folder &> /dev/null

		done
		echo "100%"
	}

	add_chezmoi_folders|progressline -m '^\d+%.*'
}

chezmoi_re_add ()
{
	gum spin --title="Re-adding" -- chezmoi re-add
	return 0
}

if [ -f "$(which gum)" ]; then
	chezmoi git add .
	if [[ ${args[--remote]} -ne 1 ]]; then
		add_settings_folders
		chezmoi_re_add
	fi
fi

gum spin --title="Updating..." -- chezmoi update --force||echo Failed to update

chezmoi git add .
git diff --cached --stat

if [[ $(git diff --numstat --staged|wc -l) -gt 0 ]]; then
	if $(gum confirm "push changes"); then
		randomstr="$(openssl rand -base64 12)"
		message="$randomstr $(date +'%d-%m-%Y')"

		if !($(gum confirm "use default message: '$message'?")); then
			message="$(gum input --placeholder 'Type a new message...')"
		fi
		git commit -m "$message"
		git push
	fi

fi

gum style --foreground 2 "Synced dots"
