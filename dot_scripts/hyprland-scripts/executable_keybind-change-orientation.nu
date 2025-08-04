#!/usr/bin/nu

# Changes the Master layout orientation and writes it to /tmp/master-orientation.txt
def main [
  orientation: string # center, left, bottom, top, center
] {

  let orientation_arg = if (["center" "left" "bottom" "top" "right"]|find $orientation|is-not-empty) {
    $orientation | save --force /tmp/master-orientation.txt
    $"orientation($orientation)"
  } else {
    "left" | save --force /tmp/master-orientation.txt
    "orientationleft"
  }

  hyprctl dispatch layoutmsg $orientation_arg
} 

