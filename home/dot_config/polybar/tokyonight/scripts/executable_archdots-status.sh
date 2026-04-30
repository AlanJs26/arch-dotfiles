if [ $(pgrep chezmoi) ]; then
  printf "󰑓 "
  exit
fi

alias count="grep -c -v '^\\s*$'"

chezmoi git add . 2>/dev/null

dots_pending=$(dots file list pending | count)

apps_unmanaged=$(dots pkg list unmanaged | rg -vU '^(::|\n)' | count)
apps_pending=$(dots pkg list pending | rg -vU '^(::|\n)' | count)

[ $dots_pending -ne 0 ] && printf "󰈙 $dots_pending "

if [ $apps_unmanaged -ne 0 ] || [ $apps_pending -ne 0 ]; then
  printf "󰏗 "
  [ $apps_pending -ne 0 ] && printf "$apps_pending󰁅 "
  [ $apps_unmanaged -ne 0 ] && printf "$apps_unmanaged󰁝"
fi
