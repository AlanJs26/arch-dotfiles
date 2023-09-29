#!/usr/bin/env bash

funcname="$1"
listen_status(){
  read player_status

  if [ "$player_status" != "Stopped" ] && [ "$player_status" != "No players found" ] && [ -n "$player_status" ]; then
    echo "($funcname)"
  else
    echo "/*ignore*/"
  fi
  # echo "$player_status"
  
  if [ -z "$1" ]; then
    listen_status 
  else
    eww update songname="$(~/.config/eww/scripts/music --song)"
    eww update artist="$(~/.config/eww/scripts/music --artist)"
    eww update icon="$(~/.config/eww/scripts/music --status)"
    eww update ctime="$(~/.config/eww/scripts/music --ctime)"
    eww update ttime="$(~/.config/eww/scripts/music --ttime)"
    eww update ptime="$(~/.config/eww/scripts/music --time)"
  fi
}

playerctl status 2>/dev/null|listen_status once
playerctl --follow status|listen_status

