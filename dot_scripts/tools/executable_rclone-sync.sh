#!/usr/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  cat <<EOF
This script is used to sync a set of folder pairs defined inside of the script with google drive.
All logs are saved in ~/.rclone.log

Usage:
 rclone-sync.sh [--bisync]

 --bisync (optional)
   Run rclone bisync command with --resync flag
 --log (optional)
   Force logging
EOF
  exit

fi

pathlinks=(
  "/mnt/DiscoExterno/_Arquivos/PDFs;drive-usp:PDFs"
  "/mnt/DiscoExterno/ObsidianVaults/USP;drive-usp:Obsidian/USP"
  "/mnt/DiscoExterno/_Codes;drive-usp:Codes"
)

exec > >(tee -a $HOME/.rclone.log) 2>&1

should_report_error=0

for item in ${pathlinks[@]}; do
  item_split=($(echo $item | rg ';' -r ' '))
  echo ${item_split[1]}

  if [[ $1 = "--bisync" ]]; then
    rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access --resync || should_report_error=1
  else

    ignored_files=$(fd '^(\.?venv|\.CondaPkg|target|build|node_modules|\.cache)$' ${item_split[0]} --no-ignore --hidden --type=directory | rg "${item_split[0]}" -r '' | awk '{print " --exclude '"'"'" $0 "'"'"'" }' | rg -U '\n' -r '')

    rclone_command=''
    if [[ $SHLVL -lt 4 ]] && [ "$1" != "--log" ]; then
      # rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access || should_report_error=1

      rclone_command="rclone sync $ignored_files '${item_split[0]}' '${item_split[1]}' --verbose || should_report_error=1"
      # rclone copy $ignored_files "${item_split[0]}" "${item_split[1]}" --verbose || should_report_error=1
    else
      # rclone bisync "${item_split[0]}" "${item_split[1]}" --verbose --check-access >> $HOME/.rclone.log 2>&1 || should_report_error=1

      rclone_command="rclone sync $ignored_files '${item_split[0]}' '${item_split[1]}' --verbose >>$HOME/.rclone.log 2>&1 || should_report_error=1"
      # rclone copy $ignored_files "${item_split[0]}" "${item_split[1]}" --verbose >>$HOME/.rclone.log 2>&1 || should_report_error=1
    fi
    echo "$rclone_command"
    eval $rclone_command
  fi

done

if [[ $should_report_error -eq 1 ]]; then
  echo "error" >$HOME/.rclone_status.txt
else
  echo "ok" >$HOME/.rclone_status.txt
fi

tail -n 2000 $HOME/.rclone.log | sponge $HOME/.rclone.log
