#!/bin/bash

cd /tmp

rawjson=$(curl -sS "https://xkcd.com/info.0.json")
# img=$(echo $rawjson|jq .img -r)
num=$(echo $rawjson|jq .num -r)

rawjson=$(curl -sS "https://xkcd.com/$((1+$RANDOM%$num))/info.0.json")
img=$(echo $rawjson|jq .img -r)

wget $img -O "$(pwd)/out.png"

convert "$(pwd)/out.png" -trim +negate +depth +dither -remap $HOME/Documentos/tools/ramp.png -background "#212534" -gravity center -resize 900x600 -extent 1360x768 "$(pwd)/out1.png"
convert "$(pwd)/out.png" -trim +negate +depth +dither -remap $HOME/Documentos/tools/ramp.png -background "#212534" -gravity center -resize 800x800 -extent 1920x1080 "$(pwd)/out2.png"
# convert "$(pwd)/out.png" -gravity center -background white -extent 1920x1080 "$(pwd)/out.png"

hydrapaper -c "$(pwd)/out2.png" "$(pwd)/out1.png" -m zoom zoom zoom || hydrapaper -c "$(pwd)/out2.png" "$(pwd)/out1.png" "$(pwd)/out2.png" -m zoom zoom zoom

echo "$(pwd)/out.png"


