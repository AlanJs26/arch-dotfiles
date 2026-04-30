#!/usr/bin/bash

pgrep dunst | xargs kill -9
gjs -m /usr/share/hyprpanel/hyprpanel-app
