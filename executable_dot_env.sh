#!/usr/bin/env sh

export ROFISTYLE="$HOME/.config/rofi/tokyonight"
export TOOLS="$HOME/.scripts/tools"
export BSPDIR="$HOME/.config/bspwm"
export BSPSETTINGS="$HOME/.scripts/settings.json"
export SCRIPTS="$HOME/.scripts"


topath=(
"$HOME/.local/share/gem/ruby/3.0.0/bin"
"$SCRIPTS/bin"
"$SCRIPTS/bspwm-scripts"
"$TOOLS"
"$TOOLS/launch"
"$HOME/.config/bspwm"
"$HOME/.local/share/chezmoi/archdots"
"$HOME/.local/bin"
"/opt/urserver"
)

for item in ${topath[@]}; do
	export PATH="$PATH:$item"
done

SSH_AUTH_SOCK="${XDG_RUNTIME_DIR}/ssh-agent.socket"

export SHELL="$(which zsh)";
export VISUAL=nvim;
export EDITOR=nvim;
export FZF_DEFAULT_OPTS='--height 60% --border --exact' 

# Flutter and Android SDK
export ANDROID_HOME=$HOME/android-sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk
export _JAVA_AWT_WM_NONREPARENTING=1

# Intel Quartus
export QSYS_ROOTDIR="/home/alan/intelFPGA_lite/23.1std/quartus/sopc_builder/bin"


if [ -f ~/.config/environment.d/profile.conf ]; then
	eval "$(cat ~/.config/environment.d/profile.conf|xargs -i echo export {})"
fi
