#!/usr/bin/nu

# Move focus in a given direction
# Toggle focus between tiled/floating when there is no window to focus up or down
def main [
  direction: string # Direction to focus. u/d/l/r
] {
  let dir_map = { u: "up", d: "down", l: "left", r: "right" }
  let lua_dir = ($dir_map | get -o $direction | default $direction)

  let activewindow = (hyprctl activewindow -j|from json) 

  if ($activewindow|is-empty) {
    hyprctl dispatch $"hl.dsp.focus\({ direction = \"($lua_dir)\" }\)"
  }

  if ($activewindow.floating == true) {
    if (["u" "d"]|find $direction|is-not-empty) {
      hyprctl dispatch 'hl.dsp.window.cycle_next({ tiled = true })'
    } else {
      # hyprctl dispatch $"hl.dsp.focus\({ direction = \"($lua_dir)\" }\)"
      if ($direction == "r") {
        hyprctl dispatch 'hl.dsp.window.cycle_next({ next = true, floating = true })'
      } else {
        hyprctl dispatch 'hl.dsp.window.cycle_next({ next = false, floating = true })'
      }
    }
    hyprctl dispatch 'hl.dsp.window.alter_zorder({ mode = "top" })'
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
        hyprctl dispatch 'hl.dsp.window.cycle_next({ floating = true })'
      } else {
        hyprctl dispatch $"hl.dsp.focus\({ direction = \"($lua_dir)\" }\)"
      }
      hyprctl dispatch 'hl.dsp.window.alter_zorder({ mode = "top" })'
    } else {
      hyprctl dispatch $"hl.dsp.focus\({ direction = \"($lua_dir)\" }\)"
    }
  }
}

