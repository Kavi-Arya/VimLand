#!/usr/bin/env bash

# 1. Find the focused window's workspace ID
focused_ws=$(niri msg windows \
  | awk '/\(focused\)/ {flag=1; next} flag && /Workspace ID/ {print $NF; exit}')

# 2. Count windows on that workspace
count=$(niri msg windows \
  | awk -v ws="$focused_ws" '/Workspace ID/ && $NF==ws {c++} END{print c+0}')

# 3. Output
echo "WORKSPACE $focused_ws:$count"
