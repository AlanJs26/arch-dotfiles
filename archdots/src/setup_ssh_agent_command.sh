#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! -f "$HOME/.config/systemd/user/ssh-agent.service" ]]; then
		echo notok
	fi
	exit
fi

if [[ ! -f "$HOME/.config/systemd/user/ssh-agent.service" ]]; then
	echo "Setting up ssh-agent systemd service"

	mkdir -p "$HOME/.config/systemd/user"
	cat "$(dirname $0)/public/ssh-agent.service" > "$HOME/.config/systemd/user/ssh-agent.service"

	mkdir -p "$HOME/.config/environment.d"
	echo "SSH_AUTH_SOCK=\"${XDG_RUNTIME_DIR}/ssh-agent.socket\"" >> "$HOME/.config/environment.d/ssh_auth_socket.conf"

	systemctl --user enable --now ssh-agent
else
	echo Alredy configured
fi



