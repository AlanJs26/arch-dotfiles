#!/usr/bin/env sh

direction="$1"
sense="$2"
# countersense is a real word, right?
if [ "$sense" = "+" ]; then
	countersense="-"
else
	countersense="+"
fi

amount=50

# First we try to resize using the bottom/right borders. If this fails (e.g. tiled) we fall back to top/left.
if [ "$direction" = "x" ]; then
	bspc node --resize "right" "${sense}${amount}" "0" ||
	bspc node --resize "left" "${countersense}${amount}" "0"
else
	bspc node --resize "bottom" "0" "${sense}${amount}" ||
	bspc node --resize "top" "0" "${countersense}${amount}"
fi
