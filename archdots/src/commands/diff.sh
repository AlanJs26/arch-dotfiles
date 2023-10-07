if [ ! $(chezmoi diff --pager 'bat') ]; then
	(cd ~/.local/share/chezmoi &&\
	git diff --cached)
fi
