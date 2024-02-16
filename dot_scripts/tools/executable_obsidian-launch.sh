#!/usr/bin/bash

rclone-sync.sh --log &
obsidian $@
