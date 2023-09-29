# echo "# this file is located in 'src/sync_all_command.sh'"
# echo "# code for 'archdots sync all' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args


[ -f "$(which gum)" ]&&gum style --foreground 212 --padding "1 4" --border rounded "Syncing Apps"
source $(dirname $0)/src/sync_apps_command.sh

[ -f "$(which gum)" ]&&gum style --foreground 212 --padding "1 4" --border rounded "Syncing Dots"
source $(dirname $0)/src/sync_dots_command.sh
