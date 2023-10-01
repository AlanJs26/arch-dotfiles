#!/usr/bin/bash

pathlinks=(
"/mnt/DiscoExterno/_Arquivos/PDFs;drive:RClone/PDFs"
"/mnt/DiscoExterno/_Arquivos/Office;drive:RClone/Office"
"/mnt/DiscoExterno/_Codes/Markdown/USP;drive:RClone/USP"
)

exec > >(tee -a $HOME/.rclone.log) 2>&1

for item in ${pathlinks[@]}; do
	item_split=($(echo $item|rg ';' -r ' '))
	echo ${item_split[1]}

	if [[ $1 = "--resync" ]]; then
		rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access --resync
	else

		if [[ $SHLVL -lt 4 ]]; then
			rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access
		else
			rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access >> $HOME/.rclone.log 2>&1
		fi
	fi

done

