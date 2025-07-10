#!/usr/bin/bash
wallpaper_path=$(cat "$HOME/.local/state/quickshell/user/generated/wallpaper/path.txt")

hyprctl hyprpaper preload "$wallpaper_path"
hyprctl hyprpaper wallpaper ",$wallpaper_path"
