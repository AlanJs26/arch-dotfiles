#!/usr/bin/env bash
result=$(/home/alan/miniconda3/bin/python /home/alan/Documentos/tools/list-scratchpad.py --list|rofi -dmenu -i -window-title "Scratchpad" -theme-str "mainbox {children: [listview];}") 
/home/alan/miniconda3/bin/python /home/alan/Documentos/tools/list-scratchpad.py --show "$result" 
