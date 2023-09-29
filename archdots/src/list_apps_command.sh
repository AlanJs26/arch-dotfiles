
if [[ ${args[--unmanaged]} -eq 1 ]]; then
	pacdef package unmanaged 2> /dev/null
elif [[ ${args[--pending]} -eq 1 ]]; then
	# Isso não funciona para pacotes que não sejam arch

	all_apps="$(cat ~/.config/pacdef/groups/*|rg -v '^(WARNING|\[|#)'|sort -u)"
	installed_apps="$(yay -Q|awk '{ print $1 }'|sort -u)"

	result=($(comm -13 <(echo "${installed_apps[@]}") <(echo "${all_apps[@]}")))
	echo $result
else
	pacdef package search '' 2> /dev/null
fi
