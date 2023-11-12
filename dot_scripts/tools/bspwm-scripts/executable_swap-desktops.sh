
next_right=$1

if [[ "$next_right" = "next" ]]; then
  next_direction="east"
else
  next_direction="west"
fi

focused_desktop_name="$(bspc query -D -d focused --names)"
next_desktop_name="$(bspc query -D -m $next_right -d .active --names)"

focused_desktop="$(bspc query -D -d focused)"
next_desktop="$(bspc query -D -m $next_right -d .active)"
direction_desktop="$(bspc query -D -m $next_direction -d .active)"

desktop_nodes () {
  bspc query -N -d $1 -n '.!hidden.!floating.window'
}

focused_nodes_number="$(desktop_nodes $focused_desktop|wc -l)"
next_nodes_number="$(desktop_nodes $next_desktop|wc -l)"

bspc config pointer_follows_focus true
if [ "$focused_nodes_number" = "1" ] && [ "$next_nodes_number" = "1" ]; then
  bspc node $(desktop_nodes $focused_desktop) --swap "$(desktop_nodes $next_desktop)"
  [ -n "$direction_desktop" ] && bspc node $(desktop_nodes $next_desktop) --focus
else
  if [ -n "$direction_desktop" ]; then
    bspc desktop "$focused_desktop" --swap $next_desktop --follow --rename "$next_desktop_name" 
    bspc desktop "$next_desktop" --rename "$focused_desktop_name"
  else
    bspc desktop "$focused_desktop" --swap $next_desktop --rename "$next_desktop_name" 
    bspc desktop "$next_desktop" --rename "$focused_desktop_name"
  fi
fi
bspc config pointer_follows_focus false
