#/bin/env bash

: <<ARCHDOTS
help: launch apps defined in config.yaml
arguments:
  - name: app
    required: false
    type: str
    nargs: '*'
    help: app alias
flags:
  - long: --list
    type: bool
    help: list all app aliases
ARCHDOTS

if [ ${args[list]} -ne 0 ]; then
  $ARCHDOTS settings query .apps
  exit
fi

app_command="$($ARCHDOTS settings query ".apps.${args[app]}" --raw)"

if [ $app_command = "null" ]; then
  echo "unknown app named '${args[app]}'"
  exit
fi

$app_command
