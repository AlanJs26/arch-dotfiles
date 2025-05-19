#!/bin/bash

tmpfile=$(mktemp tmp.XXXX.png)

maim -u -s "$tmpfile"

rapid_latex_ocr "$tmpfile" | rg 'cost: [0-9.]+$' -v | xclip -selection copy

rm $tmpfile

notify-send 'Latex OCR' "Copied to clipboard!"
