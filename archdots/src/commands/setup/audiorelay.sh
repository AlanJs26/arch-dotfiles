#!/usr/bin/env bash

if [ "$1" = "check" ]; then
  if [[ ! -f $HOME/.config/pipewire/pipewire-pulse.conf.d/audiorelay.conf ]]; then
    echo notok
  fi
  exit
fi

systemctl --user enable pipewire wireplumber pipewire-pulse
systemctl --user restart pipewire wireplumber pipewire-pulse

if [[ ! -f $HOME/.config/pipewire/pipewire-pulse.conf.d/audiorelay.conf ]]; then
  mkdir -p $HOME/.config/pipewire/pipewire-pulse.conf.d
  cp "$HOME/.local/share/chezmoi/archdots/public/audiorelay.conf" "$HOME/.config/pipewire/pipewire-pulse.conf.d"
else
  echo Already configured
fi
