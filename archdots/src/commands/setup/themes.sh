#!/usr/bin/env bash

if [ "$1" = "check" ]; then
	if [[ ! -d "$HOME/.themes/TokyoNight" ]]; then
		echo notok
	fi
	exit
fi

echo "Downloading Tokyonight GTK Theme"
[[ ! -f /tmp/master.tar.gz ]] && (cd /tmp&&wget "https://github.com/stronk-dev/Tokyo-Night-Linux/archive/refs/heads/master.tar.gz")
[[ -d /tmp/Tokyo-Night-Linux-master ]] && rm -r /tmp/Tokyo-Night-Linux-master 

(cd /tmp&&tar xvf master.tar.gz)

mkdir -p $HOME/.themes
mkdir -p $HOME/.icons
# mkdir -p "$HOME/.config/gtk-4.0"
rsync -a -v /tmp/Tokyo-Night-Linux-master/usr/share/themes/TokyoNight $HOME/.themes

# rsync -a -v "$HOME/.themes/Tokyonight-Dark-B/gtk-4.0/assets" "$HOME/.config/gtk-4.0"
# rsync -a -v "$HOME/.themes/Tokyonight-Dark-B/gtk-4.0/gtk.css" "$HOME/.config/gtk-4.0"
# rsync -a -v "$HOME/.themes/Tokyonight-Dark-B/gtk-4.0/gtk-dark.css" "$HOME/.config/gtk-4.0"
