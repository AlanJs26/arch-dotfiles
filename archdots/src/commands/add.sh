# echo "# this file is located in 'src/commands/add.sh'"
# echo "# code for 'archdots add' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

bash -c "chezmoi add ${args[file]}"
