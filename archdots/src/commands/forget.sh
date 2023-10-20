# echo "# this file is located in 'src/commands/forget.sh'"
# echo "# code for 'archdots forget' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

bash -c "chezmoi forget ${args[file]}"
