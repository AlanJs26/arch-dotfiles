
if [[ ${args[--unmanaged]} -eq 1 ]]; then
	if [[ ${args[--tree]} -eq 1 ]]; then
		tree --fromfile <(chezmoi unmanaged)
	else
		chezmoi unmanaged
	fi
else
	if [[ ${args[--tree]} -eq 1 ]]; then
		tree --fromfile <(chezmoi managed)
	else
		chezmoi managed
	fi
fi
