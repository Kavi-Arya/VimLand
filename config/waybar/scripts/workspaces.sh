#!/bin/bash

hyprland-workspaces() {
  workspace=$(hyprctl activeworkspace -j | jq '.id')
  windows=$(hyprctl activeworkspace -j | jq -r .windows)
  echo "${workspace}:${windows}"
}

niri-workspaces() {
  focused_ws=$(niri msg windows \
    | awk '/\(focused\)/ {flag=1; next} flag && /Workspace ID/ {print $NF; exit}')

  count=$(niri msg windows \
    | awk -v ws="$focused_ws" '/Workspace ID/ && $NF==ws {c++} END{print c+0}')
  echo "$focused_ws:$count"
}

if [ "$XDG_SESSION_DESKTOP" = "Hyprland" ];then
  hyprland-workspaces
elif [ "$XDG_SESSION_DESKTOP" = "niri" ];then
  niri-workspaces
else
  echo "unknown session $SESSION_TYPE"
fi
