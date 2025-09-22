#!/usr/bin/nu

# Move focus in a given direction
# Toggle focus between tiled/floating when there is no window to focus up or down
def main [
  direction: string # Direction to focus. u/d/l/r
] {
  let activewindow = (hyprctl activewindow -j|from json) 

  if ($activewindow|is-empty) {
    hyprctl dispatch movefocus $direction
  }

  if ($activewindow.floating == true) {
    if (["u" "d"]|find $direction|is-not-empty) {
      hyprctl dispatch cyclenext tiled
    } else {
      # hyprctl dispatch movefocus $direction
      if ($direction == "r") {
        hyprctl dispatch cyclenext visible floating
      } else {
        hyprctl dispatch cyclenext visible prev floating
      }
    }
    hyprctl dispatch bringactivetotop
  } else {
    if (["u" "d"]|find $direction|is-not-empty) {
      let clients = (hyprctl clients -j|from json)
      let workspace_clients = ($clients|where workspace.id == $activewindow.workspace.id and floating == false)

      def filter_workspace_clients [closure: closure] {
        ($workspace_clients|reduce --fold $activewindow {|it, acc|
          if (do $closure $it $acc) {
            $acc
          } else {
            $it
          }
        })
      }

      let lowermost = (filter_workspace_clients {|it, acc| $acc.at.1 >= $it.at.1})
      let uppermost = (filter_workspace_clients {|it, acc| $acc.at.1 <= $it.at.1})

      if (
        ($direction == "d" and $activewindow == $lowermost) 
        or ($direction == "u" and $activewindow == $uppermost)
      ) {
        hyprctl dispatch cyclenext floating
      } else {
        hyprctl dispatch movefocus $direction
      }
      hyprctl dispatch bringactivetotop
    } else {
      hyprctl dispatch movefocus $direction
    }
  }
}

