#!/usr/bin/bash

ssh_aliases=$(grep -P "^Host ([^*]+)$" $HOME/.ssh/config | sed 's/Host //')

result=$(echo "$ssh_aliases"|rofi -dmenu -i -window-title "ssh")

$(bsplaunch --query terminal) ssh $result 

