#!/bin/env bash

swayidle -w timeout 601 "niri msg action power-off-monitors" \
  timeout 600 "dms ipc call lock lock" \
  before-sleep "dms ipc call lock lock"
