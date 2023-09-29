

commands=(
"git_credentials"
"git_delta"
)

for item in ${commands[@]}; do

	if [[ "$($(dirname $0)/src/setup_${item}_command.sh check)" = "notok" ]] || [[ ${args[--force]} -eq 1 ]]; then

		gum style --foreground 212 --padding "1 4" --border rounded "Setup $item"
		source $(dirname $0)/src/setup_${item}_command.sh
	fi
done


