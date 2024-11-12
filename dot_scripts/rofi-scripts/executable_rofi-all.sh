source ~/.env.sh

mode="$(echo 'monitors
scratchpad
ssh
colorpicker
ocr
ocrlatex
shortcuts
applications
screensaver
window_class
window_name
kill_window
save_to_obsidian
zoxide' | rofi -dmenu -p 'rofi')"

ROFI_SCRIPTS=$SCRIPTS/rofi-scripts

case "$mode" in
"--list") ;;
monitors)
  $ROFI_SCRIPTS/rofi-monitors.sh
  ;;
scratchpad)
  $ROFI_SCRIPTS/rofi-scratchpad-bspwm.sh
  ;;
ssh)
  $ROFI_SCRIPTS/rofi-ssh-aliases.sh
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
  xprop | awk '/PID/ {print $3}' | xargs kill -9
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
*)
  echo "unknown argument"
  ;;
esac
