#!/usr/bin/sh

maim -s -u| tesseract stdin - -l por|xclip -selection clipboard

notify-send tesseract "Copied to clipboard!"
