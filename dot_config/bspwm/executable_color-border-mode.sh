#!/bin/env bash

: "${MARKED_NORMAL_BCOLOR:=0x6e6541}"
: "${MARKED_ACTIVE_BCOLOR:=0x827645}"
: "${MARKED_FOCUSED_BCOLOR:=0x827645}"

: "${LOCKED_NORMAL_BCOLOR:=0x6e4141}"
: "${LOCKED_ACTIVE_BCOLOR:=0x824545}"
: "${LOCKED_FOCUSED_BCOLOR:=0x824545}"

: "${PRIVATE_NORMAL_BCOLOR:=0x476e41}"
: "${PRIVATE_ACTIVE_BCOLOR:=0x4b8245}"
: "${PRIVATE_FOCUSED_BCOLOR:=0x4b8245}"

while bspc subscribe -c 1 node_swap node_focus node_flag >/dev/null; do
  bspc config focused_border_color "$(bspc config focused_border_color)"

  bspc query -N -n '.marked.!focused.!floating.window' | while read -r wid; do
    chwb -c "$MARKED_NORMAL_BCOLOR" "$wid"
  done
  bspc query -N -n '.marked.active.!focused.!floating.window' | while read -r wid; do
    chwb -c "$MARKED_ACTIVE_BCOLOR" "$wid"
  done
  bspc query -N -n "focused.!floating.marked" | while read -r wid; do
    chwb -c "$MARKED_FOCUSED_BCOLOR" "$wid"
  done

  bspc query -N -n '.locked.!focused.window' | while read -r wid; do
    chwb -c "$LOCKED_NORMAL_BCOLOR" "$wid"
  done
  bspc query -N -n '.locked.active.!focused.window' | while read -r wid; do
    chwb -c "$LOCKED_ACTIVE_BCOLOR" "$wid"
  done
  bspc query -N -n "focused.locked" | while read -r wid; do
    chwb -c "$LOCKED_FOCUSED_BCOLOR" "$wid"
  done

  bspc query -N -n '.private.!focused.window' | while read -r wid; do
    chwb -c "$PRIVATE_NORMAL_BCOLOR" "$wid"
  done
  bspc query -N -n '.private.active.!focused.window' | while read -r wid; do
    chwb -c "$PRIVATE_ACTIVE_BCOLOR" "$wid"
  done
  bspc query -N -n "focused.private" | while read -r wid; do
    chwb -c "$PRIVATE_FOCUSED_BCOLOR" "$wid"
  done

done
