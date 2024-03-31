#!/usr/bin/env bash

(cd ~/.local/share/chezmoi/archdots && bashly generate --upgrade)

cat << EOF

Now run the command below to give the configuration scripts permission to run

chmod +x \$HOME/.local/share/chezmoi/archdots/src/**/*.sh
EOF
