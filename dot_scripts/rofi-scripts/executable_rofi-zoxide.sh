#!/usr/bin/bash

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
  cat <<EOF
Helper script that spawns rofi-file-explorer given a zoxide query

Usage:
    rofi-zoxide.sh
EOF
  exit 0
fi

HISTORY=~/.cache/rofi-zoxide-history.txt
ROWS=$([ -f $HISTORY ] && echo 5 || echo 0)

# tac inverts the order of lines
results=$(cat $HISTORY 2>/dev/null | tac | rofi -dmenu -theme "~/.config/rofi/tokyonight/rofi-onecolumn.rasi" -p "zoxide" -l $ROWS -sort)
status=$?

if [ -z "$results" ]; then
  exit
fi

if [[ $status -ge 10 ]]; then
  rg -N -v "^$results$" $HISTORY | sponge $HISTORY
  $0
  exit
fi

# Append result to history
cat <<<"$results" >>$HISTORY

# Remove duplicates lines keeping order
# https://iridakos.com/programming/2019/05/16/remove-duplicate-lines-preserving-order-linux
# sponge allows to read and write to same file
awk '!visited[$0]++' $HISTORY | sponge $HISTORY

results=$(zoxide query -l | fzf --filter="$results" | head -n1)

rofi -show file-browser-extended -file-browser-dir "$results" -file-browser-cmd "$TOOLS/run.sh"
