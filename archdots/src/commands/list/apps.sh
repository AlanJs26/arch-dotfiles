
if [[ ${args[--unmanaged]} -eq 1 ]]; then
	pacdef package unmanaged 2> /dev/null
elif [[ ${args[--pending]} -eq 1 ]]; then
	# Isso não funciona para pacotes que não sejam arch


	# === filter all groups that are not related with the current config 
	pacdef_groups="$(dir -1 ~/.config/pacdef/groups/*|xargs -i basename {})"

	current_config="$(archdots alternate_config --current)"

	alternate_configs="$(archdots settings '.alternate_configs[].name' -r)"
	# remove the current config from the list containing all the alternate configs
	alternate_configs="$(cat <<< $alternate_configs|rg -v "^$current_config\$")"

	# turn a multiline string into an array
	readarray -t alternate_configs <<< $alternate_configs

	# remove all groups whose names does not match the current config
	for config in ${alternate_configs[@]}; do
		pacdef_groups="$(cat <<< $pacdef_groups|rg -v "^$config\$")"
	done

	pacdef_group_paths="$(cat <<< $pacdef_groups|awk -v HOME=$HOME '{print HOME "/.config/pacdef/groups/" $1}')"

	all_apps="$(cat $pacdef_group_paths|rg -U --multiline-dotall --pcre2 '\[arch\].+?(?=\[|\Z)'|rg -v '^(WARNING|\[|#)'|sort -u)"
	installed_apps="$(yay -Q|awk '{ print $1 }'|sort -u)"

	comm -13 <(echo "${installed_apps[@]}") <(echo "${all_apps[@]}")|awk 'NF'
else
	pacdef package search '' 2> /dev/null
fi
