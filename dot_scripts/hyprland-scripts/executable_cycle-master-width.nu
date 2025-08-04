#!/usr/bin/nu

# Cycles the Master window to predefined sizes
def main [
  --orientation: string = "center" # Master layout orientation
  --percentages: list<int> = [25 50 75] # List of percentages to cycle. Default: [25 50 75]
] {

  # Get active layout: master or dwindle
  let layout = (hyprctl getoption general:layout -j|from json|get str)
  let center_master_fallback = (hyprctl getoption master:center_master_fallback -j|from json|get str)
  let slave_count_for_center_master = (hyprctl getoption master:slave_count_for_center_master -j|from json|get int)

  let activewindow = (hyprctl activewindow -j|from json)

  # Early exit
  if ($activewindow|is-empty) {
    print Nenhuma janela em foco
    exit 1
  }

  let monitors = (hyprctl monitors -j|from json)

  let activemonitor = do {
    mut monitor = ($monitors|where focused == true)
    # Fallback
    if ($monitor|is-empty) and ($activewindow.monitor|is-not-empty) {
      $monitor = ($monitors|where id == $activewindow.monitor)
    }
    # Early exit
    if ($monitor|is-empty) {
      print Não foi possível determinar o monitor ativo
      exit 1
    }
    $monitor|first
  }

  let clients = (hyprctl clients -j|from json)

  let new_orientation = if (
    ($orientation == "center")
    and (($clients|where workspace.id == $activewindow.workspace.id|length) <= $slave_count_for_center_master)
  ) {
    $center_master_fallback
  } else {
    $orientation
  }


  let monitor_width = ($activemonitor.width)
  let monitor_height = ($activemonitor.height)

  # Helper function to filter clients in the same workspace as the active window
  # It finds one single client that follows a closure condition
  # Example: The client at the most left of the monitor
  def filter_workspace_clients [closure: closure] {
    ($clients|where workspace.id == $activewindow.workspace.id|reduce {|it, acc|
      if (do $closure $it $acc) {
        $acc
      } else {
        $it
      }
    })
  }

  let monitor_center = $activemonitor.x + $monitor_width / 2
  def win_center [win] {
    ($win.at.0 + $win.size.0 / 2)
  }

  # Find the master window. This is necessary because hyprctl does not have a 
  # command to retrieve the master window
  let targetwindow = if ($layout == "master") {

    if ($new_orientation == "left") {
      filter_workspace_clients {|it, acc| $acc.at.0 < $it.at.0}
    } else if ($new_orientation == "center") {
      filter_workspace_clients {|it, acc| 
        let acc_center_dx = (((win_center $acc) - $monitor_center)|math abs)
        let it_center_dx = (((win_center $it) - $monitor_center)|math abs)
        $acc_center_dx < $it_center_dx
      }
    } else if ($new_orientation == "right") {
      filter_workspace_clients {|it, acc| $acc.at.0 > $it.at.0}
    } else if ($new_orientation == "top") {
      filter_workspace_clients {|it, acc| $acc.at.1 < $it.at.1}
    } else if ($new_orientation == "bottom") {
      filter_workspace_clients {|it, acc| $acc.at.1 > $it.at.1}
    } else {
      print "Invalid orientation"
      exit 1
    }

    # Use the window at the extreme left when using dwindle layout
  } else {
    ($clients|where workspace.id == $activewindow.workspace.id|reduce {|it, acc|
      if ($acc.at.0 < $it.at.0) {
        $acc
      } else {
        $it
      }
    })
  }

  # Use width or height depending on orientation
  mut monitor_size = $monitor_width
  mut targetwindow_size = ($clients|where address == $targetwindow.address|first|get size.0)

  if ($layout == "master") and (["top" "bottom"]|find $new_orientation|is-not-empty) {
    $monitor_size = $monitor_height - 63
    $targetwindow_size = ($clients|where address == $targetwindow.address|first|get size.1)
  }

  # Ratio of the window relative to monitor
  let targetwindow_ratio = (($targetwindow_size * 100) / $monitor_size)

  # Find the next desired ratio
  let new_ratio = do {
    let ratio = ($percentages|where ($it - $targetwindow_ratio) > 1)
    if ($ratio|is-empty) {
      $percentages.0
    } else {
      $ratio.0
    }
  }


  # Dispatch
  if ($layout == "master") {
    hyprctl dispatch layoutmsg mfact exact ($new_ratio / 100)
  } else {
    let dx = ($new_ratio - $targetwindow_ratio) / 100 * $monitor_width
    let dy = 0

    hyprctl dispatch resizewindowpixel $dx $"($dy),address:($targetwindow.address)"
  }

}
