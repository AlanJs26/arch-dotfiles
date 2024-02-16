#!/usr/bin/bash


if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    cat <<EOF
This script is used to sync a set of folder pairs defined inside of the script with google drive.
All logs are saved in ~/.rclone.log

Usage:
 rclone-sync.sh [--resync]

 --resync (optional)
   Run rclone with --resync flag
 --log (optional)
   Force logging
EOF
exit

fi

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

		if [[ $SHLVL -lt 4 ]] && [ "$1" != "--log" ]; then
			rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access
		else
			rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access >> $HOME/.rclone.log 2>&1
		fi
	fi

done

