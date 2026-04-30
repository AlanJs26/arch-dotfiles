#!/usr/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  cat <<EOF
upgrade a package, his dependencies and packages dependent on him.  
It is basically an alias for "yay -Sy [packages] [extra args]"


Usage:
 yay-upgrade.sh [package] -- [extra_args...]
EOF
  exit
fi

normalize() {
  cat - | rg '^([^>=]+)>?=[0-9\.-]+$' -U -r '$1' --passthrough | sort -u | paste -sd ' '
}

packages="$(echo $@ | awk -F ' -- ' '{print $1}')"
extra_args="$(echo $@ | awk -F " -- " '{print $2}')"

dependencies=$(echo "$(pactree $packages -l -u | normalize) $(pactree $packages -r -l -u)" | normalize)
# dependencies=$(echo "$(pactree $packages -r -l -u)" | normalize)

yay -Sy --needed $dependencies $extra_args
