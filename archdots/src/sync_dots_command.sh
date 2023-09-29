
cd ~/.local/share/chezmoi

if [ -f "$(which gum)" ]; then
	git add .
	if [[ ${args[--remote]} -ne 1 ]] ; then
		chezmoi re-add
	fi
fi

chezmoi update||echo Failed to update

git diff --cached --stat

if [[ $(git diff --cached --numstat|wc -l) -gt 0 ]]; then
	if $(gum confirm "push changes"); then
		randomstr="$(openssl rand -base64 12)"
		message="$randomstr $(date +'%d-%m-%Y')"

		if !($(gum confirm "use default message: '$message'?")); then
			message="$(gum input --placeholder 'Type a new message...')"
		fi
		git commit -m "$message"
		git push
	fi

fi
