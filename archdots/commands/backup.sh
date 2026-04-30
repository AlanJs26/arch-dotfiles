#/bin/env bash

: <<ARCHDOTS
help: backup files using rclone
arguments:
  - name: type
    required: false
    type: str
    choices: ['pkgs', 'files']
    help: specify type of synching. Leave empty for both
flags:
  - long: --bisync
    type: bool
    help: run rclone bisync command with --resync flag
  - long: --log
    type: bool
    help: force logging
ARCHDOTS

exec > >(tee -a $HOME/.rclone.log) 2>&1

should_report_error=0

backup_len="$(dots settings query '.backup|length' --raw)"
backup="$(dots settings query .backup)"

for i in $(seq 0 $(($backup_len - 1))); do
  item="$(cat <<<$backup | jq ".[$i]")"
  action="$(cat <<<$item | jq .action -r)"
  destination="$(cat <<<$item | jq .destination -r)"
  source="$(cat <<<$item | jq .source -r)"
  ignore_patterns="$(cat <<<$item | jq '."ignore-patterns"' -r)"

  if [[ ${args[bisync]} -eq 1 ]]; then
    echo rclone bisync "${source}" "${destination}" --verbose --check-access --resync || should_report_error=1
  else
    ignored_flag=''
    if [[ $ignore_patterns != "null" ]]; then
      ignore_file_string="$(cat <<<$ignore_patterns | jq 'join("|")' -r | rg '.+' -r '^($0)$')"
      ignored_flag=$(fd $ignore_file_string $source --no-ignore --hidden --type=directory | rg "$source" -r '' | awk '{print " --exclude '"'"'" $0 "'"'"'" }' | rg -U '\n' -r '')
    fi

    rclone_command=''
    if [[ $SHLVL -lt 4 ]] && [[ ${args[log]} -eq 0 ]]; then
      rclone_command="rclone sync $ignored_flag '$source' '$destination' --verbose --delete-excluded || should_report_error=1"
    else
      rclone_command="rclone sync $ignored_flag '$source' '$destination' --verbose --delete-excluded >>$HOME/.rclone.log 2>&1 || should_report_error=1"
    fi
    echo "$rclone_command"
  fi

done

if [[ $should_report_error -eq 1 ]]; then
  echo "error" >$HOME/.rclone_status.txt
else
  echo "ok" >$HOME/.rclone_status.txt
fi

tail -n 2000 $HOME/.rclone.log | sponge $HOME/.rclone.log
