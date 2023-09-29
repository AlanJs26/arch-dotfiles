
if [[ ${args[--unmanaged]} -eq 1 ]]; then
	chezmoi unmanaged
else
	chezmoi managed
fi
