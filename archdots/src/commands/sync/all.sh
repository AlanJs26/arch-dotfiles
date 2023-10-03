# echo "# this file is located in 'src/sync_all_command.sh'"
# echo "# code for 'archdots sync all' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args


[ -f "$(which gum)" ]&&gum style --foreground 212 --padding "1 4" --border rounded "Syncing Apps"
source "$HOME/.local/share/chezmoi/archdots/src/commands/sync/apps.sh"

[ -f "$(which gum)" ]&&gum style --foreground 212 --padding "1 4" --border rounded "Syncing Dots"
source "$HOME/.local/share/chezmoi/archdots/src/commands/sync/dots.sh"
