#!/usr/bin/env sh

topath=(
"$HOME/.local/share/gem/ruby/3.0.0/bin"
"$HOME/.scripts/tools"
"$HOME/.local/share/chezmoi/archdots"
)

for item in ${topath[@]}; do
	export PATH="$PATH:$item"
done


# export GIT_PAGER="bat"
export SHELL="$(which zsh)";
export VISUAL=nvim;
export EDITOR=nvim;
export FZF_DEFAULT_OPTS='--height 60% --border --exact' 

