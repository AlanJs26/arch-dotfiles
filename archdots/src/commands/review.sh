# echo "# this file is located in 'src/review_command.sh'"
# echo "# code for 'archdots review' goes here"
# echo "# you can edit it freely and regenerate (it will not be overwritten)"
# inspect_args

# pacdef package review 2> /dev/null
archdots_path=$HOME/.local/share/chezmoi/archdots/src
$archdots_path/archdots_py/.venv/bin/python3 $archdots_path/archdots_py/src/review.py 
