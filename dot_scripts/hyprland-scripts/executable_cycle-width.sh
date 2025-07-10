#!/bin/bash

# --- Configuration ---
# Define the desired width percentage values here, separated by spaces.
# It's assumed these are sorted in increasing order for the logic below.
width_percentages=(25 50 75) # Percentage values for width

# --- Script Logic ---

if ! command -v jq &>/dev/null; then
  echo "jq não está instalado. Por favor, instale jq para executar este script."
  exit 1
fi

active_window_hex=$(hyprctl activewindow -j | jq -r '.address')
if [ -z "$active_window_hex" ] || [ "$active_window_hex" == "null" ]; then
  # No active window, nothing to do.
  exit 1
fi

# Get monitor and active window info
active_monitor_json="$(hyprctl monitors -j | jq '.[] | select(.focused == true)')"
if [ -z "$active_monitor_json" ] || [ "$active_monitor_json" == "null" ]; then
  # Fallback if no monitor has .focused (e.g. overview mode), try to find monitor with the active window
  active_window_monitor_id=$(hyprctl activewindow -j | jq -r '.monitor')
  if [ -n "$active_window_monitor_id" ] && [ "$active_window_monitor_id" != "null" ]; then
    active_monitor_json="$(hyprctl monitors -j | jq --argjson id "$active_window_monitor_id" '.[] | select(.id == $id)')"
  fi
fi

if [ -z "$active_monitor_json" ] || [ "$active_monitor_json" == "null" ]; then
  echo "Não foi possível determinar o monitor ativo."
  exit 1
fi

monitor_width_px=$(cat <<<"$active_monitor_json" | jq -r '.width')

target_window_address="$(hyprctl clients -j | jq -r "[.[] | select (.workspace.id == $(hyprctl activewindow -j | jq .workspace.id))] | min_by(.at[0]) | .address")"

# current_window_width_px=$(hyprctl activewindow -j | jq -r '.size[0]')
window_width_px=$(hyprctl clients -j | jq -r ".[] | select (.address==\"$target_window_address\") | .size[0]")

if [ -z "$monitor_width_px" ] || [ "$monitor_width_px" -le 0 ] || [ -z "$window_width_px" ]; then
  echo "Não foi possível obter as dimensões necessárias do monitor ou da janela."
  exit 1
fi

# 1. Calculate the current window's width percentage relative to the monitor
# Using integer arithmetic (bash default)
actual_current_width_percentage=$(((window_width_px * 100) / monitor_width_px))

# 2. Choose the next predefined percentage index
# Find the smallest predefined percentage that is strictly greater than the actual current percentage.
# If none is found (current is >= all predefined), cycle to the first predefined percentage.
target_percentage_value=${width_percentages[0]} # Default to the first
next_target_index=0
found_next=false

for i in "${!width_percentages[@]}"; do
  if ((${width_percentages[$i]} > actual_current_width_percentage)); then
    target_percentage_value=${width_percentages[$i]}
    next_target_index=$i
    found_next=true
    break
  fi
done

# 3. Calculate the target width in pixels based on the chosen target_percentage_value
target_window_width_px=$(((monitor_width_px * target_percentage_value) / 100))

cat <<<$target_window_width_px
cat <<<$window_width_px

# 4. Calculate the difference (dx) for resizeactive
dx=$((target_window_width_px - window_width_px))
dy=0 # We are not changing the height, so dy is 0

# 5. Form and execute the hyprctl command
resize_command_delta="$dx $dy"

# Debug output (optional)
# echo "Monitor Width: $monitor_width_px px"
# echo "Current Window Width: $window_width_px px ($actual_current_width_percentage%)"
# echo "Target Predefined Percentage: $target_percentage_value% (Index: $next_target_index)"
# echo "Target Window Width: $target_window_width_px px"
# echo "Calculated dx: $dx, dy: $dy"
# echo "Command: hyprctl dispatch resizeactive $resize_command_delta"

echo $target_window_address
hyprctl dispatch resizewindowpixel $resize_command_delta,address:$target_window_address
