#!/usr/bin/bash

ssh_aliases=$(grep -P "^Host ([^*]+)$" $HOME/.ssh/config | sed 's/Host //')

result=$(echo "$ssh_aliases" | rofi -dmenu -i -window-title "ssh")

$(dots settings query .apps.terminal --raw) ssh $result
