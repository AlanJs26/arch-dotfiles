#!/usr/bin/env sh

topath=(
"$HOME/.local/share/gem/ruby/3.0.0/bin"
"$HOME/.scripts/tools"
"$HOME/.scripts/tools/bspwm-scripts"
"$HOME/.local/share/chezmoi/archdots"
"$HOME/.local/bin"
"/opt/urserver"
)

for item in ${topath[@]}; do
	export PATH="$PATH:$item"
done

export NEOVIDE_MULTIGRID=1
SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

export ROFISTYLE="$HOME/.config/rofi/tokyonight"
export TOOLS="$HOME/.scripts/tools"
export BSPDIR="$HOME/.config/bspwm"

export SHELL="$(which zsh)";
export VISUAL=nvim;
export EDITOR=nvim;
export FZF_DEFAULT_OPTS='--height 60% --border --exact' 


export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export GLFW_IM_MODULE=ibus
