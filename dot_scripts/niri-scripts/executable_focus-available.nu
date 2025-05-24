#!/usr/bin/nu

let focused_workspace_id = try {
  niri msg --json focused-window|from json|get workspace_id
} catch {
  if (niri msg --json overview-state|from json).is_open {
    niri msg action focus-workspace-down
  } else {
    niri msg action focus-workspace 0
  }
  exit
}
mut windows = (niri msg --json windows|from json)
let workspaces = (niri msg --json workspaces|from json)


let focused_workspace_idx = ($workspaces|find --columns [id] $focused_workspace_id).idx.0


let focused_output = ($workspaces|find true --columns [is_focused]|get output).0
let workspaces_on_output = ($workspaces|filter {||$in.output == $focused_output})

let windows_on_output = ($windows|filter {|win| 
  $workspaces_on_output|any {|workspace| $workspace.id == $win.workspace_id}
})
let idx_on_output = $windows|each {|win| 
  $workspaces_on_output|find $win.workspace_id --columns [id]|get idx.0?
}

if ($idx_on_output|filter {||$in > $focused_workspace_idx}|is-not-empty) {
  niri msg action focus-workspace-down
} else {
  niri msg action focus-workspace 0
}

