#!/bin/bash

# see man zscroll for documentation of the following parameters
zscroll -l 30 \
        --delay 2 \
        --scroll-padding "  " \
        --match-command "$HOME/.config/polybar/tokyonight/scripts/get_spotify_status.sh --status" \
        --match-text "Playing" "--scroll 1 --before-text ' '" \
        --match-text "Paused" "--scroll 0 --before-text '󰏤 '" \
        --match-text "none" "--scroll 0 --before-text ''" \
        --update-check true "$HOME/.config/polybar/tokyonight/scripts/get_spotify_status.sh" &

wait
