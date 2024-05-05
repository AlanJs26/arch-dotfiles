

function trailing_slash(){
	if [[ -z "${args[--fast]}" ]]; then
		cat < /dev/stdin|xargs -i sh -c '[ "$(file --brief "$HOME/{}")" = "directory" ]&&echo "{}/"||echo {}'
	else
		cat < /dev/stdin
	fi
}

get_level() {
	if [[ -n "${args[--level]}" ]]; then
		echo "${args[--level]}"
		exit
	fi
	echo -e "99"
}

show_managed () {
	eval "data=(${args[folder]})"
	
	if [[ ${args[--tree]} -eq 1 ]]; then
		if [ -z "$data" ] || [[ "$(readlink -f "$data")" = "$HOME" ]]; then
			tree -L $(get_level) --fromfile <(chezmoi managed|trailing_slash )
		else
			tree -L $(get_level) --fromfile <(chezmoi managed $data|trailing_slash)
		fi
	else
		if [ -z "$data" ] || [[ "$(readlink -f "$data")" = "$HOME" ]]; then
			chezmoi managed
		else
			chezmoi managed $data
		fi
	fi
}

show_unmanaged () {
	eval "data=(${args[folder]})"
	# data=$(echo $data|sed "s:$HOME/::")

	if [[ ${args[--tree]} -eq 1 ]]; then
		tree -L $(get_level) --fromfile <(chezmoi unmanaged $data|trailing_slash)
	else
		chezmoi unmanaged $data
	fi
}

show_pending () {
	from_git="$(archdots git diff --cached --numstat|awk '{print $3}'|rg 'dot_' -r '.' --passthrough|sed 's/private_|executable_//g')" 
	from_chezmoi="$(chezmoi diff|rg 'diff --git'|rg 'a/(.+) b/' -o -r '$1')"

	pending="$(echo -e "$from_git\n$from_chezmoi"|sort -u)"

	if [[ ${args[--tree]} -eq 1 ]]; then
		tree -L $(get_level) --fromfile <(cat <<< "$pending"|trailing_slash)
	else
		cat <<< "$pending"
	fi
}


if [[ ${args[--managed]} -eq 1 ]]; then
	show_managed
elif [[ ${args[--unmanaged]} -eq 1 ]]; then
	show_unmanaged
elif [[ ${args[--pending]} -eq 1 ]]; then
	show_pending
else
	show_managed
fi
