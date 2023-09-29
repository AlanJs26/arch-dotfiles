#!/bin/bash

if [[ $1 == *.md ]]; then
    /usr/bin/node '/home/alan/Documentos/tools/parseMarkdown.js' "$1"
    /home/alan/miniconda3/bin/python '/home/alan/Documentos/Codes/Python/Text Processing/docxTest/main.py' "./tmp.md" -o $1
    rm tmp.md
    exit
fi

/home/alan/miniconda3/bin/python '/home/alan/Documentos/Codes/Python/Text Processing/docxTest/main.py' "$@"
