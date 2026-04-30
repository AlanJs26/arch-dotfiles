#!/bin/sh
is_zellij_running ()
{
  kitten @ ls| jq '.[]|select(.is_active).tabs[]|select(.is_focused).windows[0].foreground_processes[0].cmdline|any(test("zellij"))'
}
 
if [ "$(is_zellij_running)" = "true" ]; then
  case "$1" in
    new_tab)
      kitten @ send-text "\ctn" 
      sleep 0.1
      ;;
    next_tab)
      kitten @ send-text "\ctl\r" 
      ;;
    previous_tab)
      kitten @ send-text "\cth\r" 
      ;;
    close_tab)
      kitten @ send-text "\ctx" 
      ;;
  esac
else
  case "$1" in
    new_tab)
      kitten @ launch --type=tab
      ;;
    next_tab)
      kitten @ launch --type=tab
      ;;
    previous_tab)
      kitten @ send-text "\cth\r" 
      ;;
    close_tab)
      kitten @ send-text "\ctx" 
      ;;
  esac
fi
