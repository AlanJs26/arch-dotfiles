if [[ ! $(chezmoi diff) ]]; then
	(cd ~/.local/share/chezmoi && git diff --cached)
else
	chezmoi diff --reverse --pager 'delta'
fi
