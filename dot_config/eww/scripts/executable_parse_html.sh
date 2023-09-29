#!/usr/bin/env zsh

read -d '' foo

to_remove=(
  "web\.whatsapp\.com"
)

output=$(print "$foo"|rg '<.+?>(.+?)</.+?>' -r '$1' --passthru)

for item in "${to_remove[@]}"; do
  output=$(print "$output"|rg "$item" -r '' --passthru)
done

if [ -n "$output" ]; then
  printf "%s" "$output"
else
  printf "%s" "$foo"
fi


