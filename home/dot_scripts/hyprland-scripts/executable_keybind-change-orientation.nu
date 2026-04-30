#!/usr/bin/nu

# Changes the Master layout orientation and writes it to /tmp/master-orientation.txt
def main [
  orientation: string # right, left, bottom, top, center
] {
  let layout = (hyprctl getoption general:layout -j|from json|get str)

  if $layout == "dwindle" {
    hyprctl keyword binds:window_direction_monitor_fallback false
    let dir = (match $orientation { 
      "bottom"|"center" => "b",
      "right" => "r",
      "left" => "l",
      "top" => "u",
    })
    hyprctl dispatch movewindow $dir
    hyprctl keyword binds:window_direction_monitor_fallback true
    exit
  }

  let orientation_arg = if (["center" "left" "bottom" "top" "right"]|find $orientation|is-not-empty) {
    $orientation | save --force /tmp/master-orientation.txt
    $"orientation($orientation)"
  } else {
    "left" | save --force /tmp/master-orientation.txt
    "orientationleft"
  }

  hyprctl dispatch layoutmsg $orientation_arg
} 

