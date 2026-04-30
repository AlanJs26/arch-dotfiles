#!/usr/bin/bash

set -e

wl-paste --type image --watch cliphist store &
wl-paste --type text --watch cliphist store
