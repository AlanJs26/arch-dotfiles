#!/usr/bin/nu

# Get active layout: master or dwindle
let layout = (hyprctl getoption general:layout -j|from json|get str)
let center_master_fallback = (hyprctl getoption master:center_master_fallback -j|from json|get str)
let slave_count_for_center_master = (hyprctl getoption master:slave_count_for_center_master -j|from json|get int)
# --- NOVO: OBTÉM O TAMANHO DA BORDA ---
let border_size = (hyprctl getoption general:border_size -j|from json|get int)

# Handles resizing and centering for floating windows, ensuring it stays on screen.
# Now supports "sticky" edges, reserved screen space, and window borders.
def handle_float [
  activewindow: record,
  percentages: list<int>,
  activemonitor: record,
  direction: string,
  border_size: int # <-- Novo parâmetro
] {
  let is_vertical = ($direction == "vertical")

  # Monitor properties
  let monitor_x = $activemonitor.x
  let monitor_y = $activemonitor.y
  let monitor_width = $activemonitor.width
  let monitor_height = $activemonitor.height

  # Calculate usable area using 'reserved'
  let reserved_top = $activemonitor.reserved.1
  let reserved_bottom = $activemonitor.reserved.3
  let reserved_left = $activemonitor.reserved.0
  let reserved_right = $activemonitor.reserved.2
  let usable_x = $monitor_x + $reserved_left
  let usable_y = $monitor_y + $reserved_top
  let usable_right_edge = ($monitor_x + $monitor_width) - $reserved_right
  let usable_bottom_edge = ($monitor_y + $monitor_height) - $reserved_bottom

  # Generalize properties based on direction
  let monitor_size = if $is_vertical { $monitor_height } else { $monitor_width }
  let current_size = if $is_vertical { $activewindow.size.1 } else { $activewindow.size.0 }
  let current_pos = if $is_vertical { $activewindow.at.1 } else { $activewindow.at.0 }

  # Ratio of the window relative to monitor
  let current_ratio = (($current_size * 100) / $monitor_size)

  # Find the next desired ratio from the cycle
  let new_ratio = do {
    let ratio = ($percentages|where ($it - $current_ratio) > 1)
    if ($ratio|is-empty) { $percentages.0 } else { $ratio.0 }
  }

  # Calculate the new size in pixels
  let new_size = (($monitor_size * $new_ratio) / 100 | math round)

  # --- ATUALIZADO: DETECÇÃO DE BORDA CONSIDERA O TAMANHO DA BORDA ---
  let tolerance = 10
  let is_stuck_left = (($activewindow.at.0 - $border_size) - $usable_x) <= $tolerance
  let is_stuck_right = ($usable_right_edge - ($activewindow.at.0 + $activewindow.size.0 + $border_size)) <= $tolerance
  let is_stuck_top = (($activewindow.at.1 - $border_size) - $usable_y) <= $tolerance
  let is_stuck_bottom = ($usable_bottom_edge - ($activewindow.at.1 + $activewindow.size.1 + $border_size)) <= $tolerance

  # Conditional positioning logic
  mut final_width = $activewindow.size.0
  mut final_height = $activewindow.size.1
  mut final_x = $activewindow.at.0
  mut final_y = $activewindow.at.1

  if $is_vertical {
    $final_height = $new_size
    let old_center_y = ($activewindow.at.1 + ($activewindow.size.1 / 2))
    $final_y = (($old_center_y - ($final_height / 2)) | math round)

    # --- ATUALIZADO: POSICIONAMENTO CONSIDERA A BORDA ---
    if $is_stuck_top { $final_y = $usable_y + $border_size }
    if $is_stuck_bottom { $final_y = ($usable_bottom_edge - $final_height - $border_size) }

  } else { # Horizontal
    $final_width = $new_size
    let old_center_x = ($activewindow.at.0 + ($activewindow.size.0 / 2))
    $final_x = (($old_center_x - ($final_width / 2)) | math round)

    # --- ATUALIZADO: POSICIONAMENTO CONSIDERA A BORDA ---
    if $is_stuck_left { $final_x = $usable_x + $border_size }
    if $is_stuck_right { $final_x = ($usable_right_edge - $final_width - $border_size) }
  }

  # --- ATUALIZADO: PROTEÇÃO FINAL CONSIDERA A BORDA ---
  if ($final_x + $final_width + $border_size) > $usable_right_edge { $final_x = ($usable_right_edge - $final_width - $border_size) }
  if ($final_x - $border_size) < $usable_x { $final_x = $usable_x + $border_size }
  if ($final_y + $final_height + $border_size) > $usable_bottom_edge { $final_y = ($usable_bottom_edge - $final_height - $border_size) }
  if ($final_y - $border_size) < $usable_y { $final_y = $usable_y + $border_size }


  # Dispatch commands to Hyprland
  hyprctl dispatch resizewindowpixel $"exact ($final_width) ($final_height),address:($activewindow.address)"
  hyprctl dispatch movewindowpixel $"exact ($final_x) ($final_y),address:($activewindow.address)"
}


# Cycles the Master/focused window to predefined sizes
def main [
  --orientation: string = "center"      # Master layout orientation
  --percentages: list<int> = [25 50 75] # List of percentages to cycle. Default: [25 50 75]
  --direction: string = "horizontal"    # Direction to resize: "horizontal" or "vertical"
] {
  let activewindow = (hyprctl activewindow -j|from json)

  if ($activewindow|is-empty) {
    print "Nenhuma janela em foco"
    exit 1
  }

  let monitors = (hyprctl monitors -j|from json)

  let activemonitor = do {
    mut monitor = ($monitors|where focused == true)
    if ($monitor|is-empty) and ($activewindow.monitor|is-not-empty) {
      $monitor = ($monitors|where id == $activewindow.monitor)
    }
    if ($monitor|is-empty) {
      print "Não foi possível determinar o monitor ativo"
      exit 1
    }
    $monitor|first
  }

  # --- VERIFICAÇÃO DE JANELA FLUTUANTE ---
  if $activewindow.floating {
    # Passa o tamanho da borda para a função
    handle_float $activewindow $percentages $activemonitor $direction $border_size
    exit 0
  } else if ($layout == "dwindle") {
    hyprctl dispatch layoutmsg movetoroot
    exit 0
  }

  # --- LÓGICA PARA JANELAS LADO A LADO (TILED) ---
  let clients = (hyprctl clients -j|from json)
  let is_vertical = ($orientation == "top" or $orientation == "bottom")

  let new_orientation = if (
    ($orientation == "center")
    and (($clients|where workspace.id == $activewindow.workspace.id|length) <= $slave_count_for_center_master)
  ) {
    $center_master_fallback
  } else {
    $orientation
  }

  let reserved_top = $activemonitor.reserved.1
  let reserved_bottom = $activemonitor.reserved.3
  let reserved_left = $activemonitor.reserved.0
  let reserved_right = $activemonitor.reserved.2

  let monitor_width = ($activemonitor.width - $reserved_right - $reserved_left)
  let monitor_height = ($activemonitor.height - $reserved_top - $reserved_bottom)

  def filter_workspace_clients [closure: closure] {
    ($clients|where workspace.id == $activewindow.workspace.id|reduce {|it, acc|
      if (do $closure $it $acc) { $acc } else { $it }
    })
  }

  let monitor_center = $activemonitor.x + $monitor_width / 2
  def win_center [win] { ($win.at.0 + $win.size.0 / 2) }

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
  } else { # dwindle layout
    ($clients|where workspace.id == $activewindow.workspace.id|reduce {|it, acc|
      if ($acc.at.0 < $it.at.0) { $acc } else { $it }
    })
  }

  # Use width/height and size based on the 'direction' parameter
  let monitor_size = if $is_vertical { $monitor_height } else { $monitor_width }
  let targetwindow_size = if $is_vertical {
    ($clients|where address == $targetwindow.address|first|get size.1)
  } else {
    ($clients|where address == $targetwindow.address|first|get size.0)
  }

  let targetwindow_ratio = (($targetwindow_size * 100) / $monitor_size)

  let new_ratio = do {
    let ratio = ($percentages|where ($it - $targetwindow_ratio) > 2)
    if ($ratio|is-empty) { $percentages.0 } else { $ratio.0 }
  }

  # Dispatch command based on layout and direction
  if ($layout == "master") {
    hyprctl dispatch layoutmsg mfact exact ($new_ratio / 100)
  } else { # dwindle
    if $is_vertical {
      let dy = (($new_ratio - $targetwindow_ratio) / 100 * $monitor_height | math round)
      hyprctl dispatch resizewindowpixel $"0 ($dy),address:($targetwindow.address)"
    } else {
      let dx = (($new_ratio - $targetwindow_ratio) / 100 * $monitor_width | math round)
      hyprctl dispatch resizewindowpixel $"($dx) 0,address:($targetwindow.address)"
    }
  }
}
