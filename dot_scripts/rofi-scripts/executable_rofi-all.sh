#!/usr/bin/bash

source ~/.env.sh

mode=''
case "$XDG_CURRENT_DESKTOP" in
"Hyprland")
  mode="$(echo 'record
ssh
colorpicker
ocr
ocrlatex
applications
prop
kill_window
save_to_obsidian
save_to_thunderatz
power
zoxide' | rofi -dmenu -p 'rofi')"
  ;;
"niri")
  mode="$(echo 'record
ssh
colorpicker
ocr
ocrlatex
applications
save_to_obsidian
save_to_thunderatz
power
zoxide' | rofi -dmenu -p 'rofi')"
  ;;
*)
  mode="$(echo 'monitors
scratchpad
ssh
colorpicker
ocr
ocrlatex
record
shortcuts
applications
screensaver
prop
window_class
window_name
kill_window
save_to_obsidian
save_to_thunderatz
power
zoxide' | rofi -dmenu -p 'rofi')"
  ;;
esac

ROFI_SCRIPTS=$SCRIPTS/rofi-scripts

case "$mode" in
"--list") ;;
prop)
  if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    kitty bash -c 'hyprprop; echo Press ENTER to continue; read -n 1'
  else
    kitty bash -c 'xprop; echo Press ENTER to continue; read -n 1'
  fi
  ;;
monitors)
  $ROFI_SCRIPTS/rofi-monitors.sh
  ;;
scratchpad)
  $ROFI_SCRIPTS/rofi-scratchpad-bspwm.sh
  ;;
ssh)
  $ROFI_SCRIPTS/rofi-ssh-aliases.sh
  ;;
record)
  $ROFI_SCRIPTS/rofi-record.sh
  ;;
colorpicker)
  colorpicker-selection.sh
  ;;
ocr)
  ocr-selection.sh
  ;;
ocrlatex)
  ocrlatex-selection.sh
  ;;
shortcuts)
  $HOME/.config/sxhkd/sxhkd-help
  ;;
zoxide)
  $ROFI_SCRIPTS/rofi-zoxide.sh
  ;;
applications)
  rofi -show drun
  ;;
screensaver)
  $ROFI_SCRIPTS/rofi-lockscreen.sh
  ;;
kill_window)
  if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ]; then
    hyprprop | jq .pid | xargs kill -9
  else
    xprop | awk '/PID/ {print $3}' | xargs kill -9
  fi
  ;;
window_class)
  wmname=$(xprop | rg "^WM_CLASS.+\"(.+?)\"" -r '$1')
  printf "%s" "$wmname" | xclip -sel copy
  notify-send "WM_CLASS" "$wmname"
  ;;
window_name)
  wmname=$(xprop | rg "^WM_NAME.+\"(.+?)\"" -r '$1')
  printf "%s" "$wmname" | xclip -sel copy
  notify-send "WM_NAME" "$wmname"
  ;;
save_to_obsidian)
  $ROFI_SCRIPTS/rofi-save-to-obsidian.nu
  ;;
save_to_thunderatz)
  $ROFI_SCRIPTS/rofi-save-to-obsidian.nu --subfolder ThundeRatz
  ;;
power)
  rofi -show power-menu -modi "power-menu:rofi-power-menu --choices=lockscreen/shutdown/reboot/logout/suspend/hibernate"
  ;;
*)
  echo "unknown argument"
  ;;
esac
