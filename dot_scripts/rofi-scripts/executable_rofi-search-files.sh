#!/usr/bin/env zsh

search_query="/mnt/DiscoExterno/_Codes/Markdown/USP/6 Semestre"
search_extensions=(-e png -e jpeg -e pdf -e jpg)

function parse_file() {
  case "$1" in
  *pdf)
    echo pdf
    ;;
  *)
    echo $1
    ;;
  esac
}
IFS=$'\n' files=($(fd $search_extensions . $search_query))

result=$(for f in $files; do
  icon="$(parse_file $f)"

  echo -en "$(basename "$f")\0icon\x1f$icon\x1fmeta\x1f$f\n"
done | rofi -dmenu -format i -i -p 'Files: ')
if [ -n "$result" ]; then
  notify-send "file" $result
fi
