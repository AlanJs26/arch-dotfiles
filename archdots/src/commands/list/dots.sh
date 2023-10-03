
if [[ ${args[--unmanaged]} -eq 1 ]]; then

	if [[ ${args[--tree]} -eq 1 ]]; then
		tree --fromfile <(chezmoi unmanaged)
	else
		chezmoi unmanaged
	fi

elif [[ ${args[--pending]} -eq 1 ]]; then

	if [[ ${args[--tree]} -eq 1 ]]; then
		tree --fromfile <(archdots git diff --cached --numstat|awk '{print $3}')
	else
		archdots git diff --cached --numstat|awk '{print $3}'
	fi

else

	if [[ ${args[--tree]} -eq 1 ]]; then
		tree --fromfile <(chezmoi managed)
	else
		chezmoi managed
	fi
fi
