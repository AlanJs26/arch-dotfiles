#!/usr/bin/bash

niri msg action switch-preset-column-width
niri msg action focus-column-right
niri msg action set-column-width 50
sleep 0.01
niri msg action focus-column-left
niri msg action focus-column-right
sleep 0.02
niri msg action expand-column-to-available-width
niri msg action focus-column-left
