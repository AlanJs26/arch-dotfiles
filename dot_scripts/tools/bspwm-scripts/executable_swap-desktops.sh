
next_right=$1

focused_desktop_name="$(bspc query -D -d focused --names)"
last_desktop_name="$(bspc query -D -m $next_right -d .active --names)"

focused_desktop="$(bspc query -D -d focused)"
last_desktop="$(bspc query -D -m $next_right -d .active)"

desktop_nodes () {
  bspc query -N -d $1 -n '.!hidden.!floating.window'
}

focused_nodes_number="$(desktop_nodes $focused_desktop|wc -l)"
last_nodes_number="$(desktop_nodes $last_desktop|wc -l)"

bspc config pointer_follows_focus true
if [ "$focused_nodes_number" = "1" ] && [ "$last_nodes_number" = "1" ]; then
  bspc node $(desktop_nodes $focused_desktop) -s "$(desktop_nodes $last_desktop)"
  bspc node $(desktop_nodes $last_desktop) --focus
else
  bspc desktop "$last_desktop"    --to-monitor focused     && bspc desktop -f "$last_desktop"    -n "$last_desktop_name"
  bspc desktop "$focused_desktop" --to-monitor $next_right && bspc desktop -f "$focused_desktop" -n "$focused_desktop_name"
fi
bspc config pointer_follows_focus false
