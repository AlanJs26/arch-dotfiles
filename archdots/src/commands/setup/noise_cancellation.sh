#!/usr/bin/env bash

if [ "$1" = "check" ]; then
  if [[ ! -d /usr/lib/linux-rnnoise ]]; then
    echo notok
  fi
  exit
fi

mkdir -p $HOME/.config/pipewire/pipewire-pulse.conf.d

wget https://github.com/werman/noise-suppression-for-voice/releases/latest/download/linux-rnnoise.zip
unzip linux-rnnoise.zip
rm linux-rnnoise.zip
sudo mv linux-rnnoise /usr/lib

cp "$HOME/.local/share/chezmoi/archdots/public/99-input-denoising.conf" "$HOME/.config/pipewire/pipewire-pulse.conf.d"

systemctl --user enable pipewire wireplumber pipewire-pulse
systemctl --user restart pipewire wireplumber pipewire-pulse
