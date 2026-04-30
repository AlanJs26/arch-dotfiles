#!/usr/bin/sh

# moduleIndex=$(pactl load-module module-null-sink \
# 	sink_name=audiorelay-virtual-mic-sink \
# 	sink_properties=device.description=Virtual-Mic-Sink)
# audiorelay && pactl unload-module $moduleIndex
audiorelay
