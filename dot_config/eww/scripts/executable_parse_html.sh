#!/usr/bin/env zsh

read -d '' stdin

to_remove=(
  'web.whatsapp.com'
)

output=$(cat <<< "$stdin"|rg '<.+?>(.+?)</.+?>' -r '$1' --passthru)

for item in "${to_remove[@]}"; do
  output=$(cat <<< "$output"|rg "$item" -r '' --passthru)
done

if [ -n "$output" ]; then
  cat <<< "$output"
else
  cat <<< "$stdin"
fi


