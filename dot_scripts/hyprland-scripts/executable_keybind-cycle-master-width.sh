#!/usr/bin/bash

orientation=$(cat /tmp/master-orientation.txt 2>/dev/null)
$HOME/.scripts/hyprland-scripts/cycle-master-width.nu --orientation ${orientation:-left} --direction ${1:-horizontal}
