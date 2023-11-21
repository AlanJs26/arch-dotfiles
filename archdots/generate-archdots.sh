#!/usr/bin/env bash

(cd ~/.local/share/chezmoi/archdots && bashly generate --upgrade)
chmod +x $HOME/.local/share/chezmoi/archdots/src/**/*.sh
