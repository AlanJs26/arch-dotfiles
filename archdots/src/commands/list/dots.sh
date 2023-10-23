
if [[ ${args[--unmanaged]} -eq 1 ]]; then

	if [[ ${args[--tree]} -eq 1 ]]; then
		tree --fromfile <(chezmoi unmanaged)
	else
		chezmoi unmanaged
	fi

elif [[ ${args[--pending]} -eq 1 ]]; then
	from_git="$(archdots git diff --cached --numstat|awk '{print $3}'|rg 'dot_' -r '.' --passthrough|sed 's/private_|executable_//g')" 
	from_chezmoi="$(chezmoi diff|rg 'diff --git'|rg 'a/(.+) b/' -o -r '$1')"

	pending="$(echo -e "$from_git\n$from_chezmoi"|sort -u)"

	if [[ ${args[--tree]} -eq 1 ]]; then
		tree --fromfile <(echo "$pending")
	else
		echo "$pending"
	fi

else

	if [[ ${args[--tree]} -eq 1 ]]; then
		tree --fromfile <(chezmoi managed)
	else
		chezmoi managed
	fi
fi
