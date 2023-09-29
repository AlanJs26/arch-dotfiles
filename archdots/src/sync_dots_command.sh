
chezmoi git add .
chezmoi apply
chezmoi update||echo Failed to update

cd ~/.local/share/chezmoi
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
