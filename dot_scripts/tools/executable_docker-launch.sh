#!/bin/bash

echo "Starting docker daemon"
nohup sudo /usr/bin/dockerd -H unix:// --iptables=false 2>&1 & disown
