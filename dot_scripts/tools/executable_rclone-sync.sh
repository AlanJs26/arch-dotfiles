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
"/mnt/DiscoExterno/_Arquivos/PDFs;drive-usp:PDFs"
"/mnt/DiscoExterno/_Codes/Markdown/USP;drive-usp:Obsidian/USP"
)
# "/mnt/DiscoExterno/_Arquivos/Office;drive-usp:Shared/Office"

exec > >(tee -a $HOME/.rclone.log) 2>&1

should_report_error=0

for item in ${pathlinks[@]}; do
	item_split=($(echo $item|rg ';' -r ' '))
	echo ${item_split[1]}

	if [[ $1 = "--resync" ]]; then
		rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access --resync || should_report_error=1
	else

		if [[ $SHLVL -lt 4 ]] && [ "$1" != "--log" ]; then
			rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access || should_report_error=1
		else
			rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access >> $HOME/.rclone.log 2>&1 || should_report_error=1
		fi
	fi

done


if [[ $should_report_error -eq 1 ]]; then
	echo "error" > $HOME/.rclone_status.txt
else
	echo "ok" > $HOME/.rclone_status.txt
fi
