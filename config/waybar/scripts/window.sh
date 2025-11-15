#!/bin/bash

hyprland-window() {
  CLASS=$(hyprctl activewindow -j | jq ".class" -r)
  TITLE=$(hyprctl activewindow -j | jq ".title" -r | sed -E 's/^(.{45}).+$/\1.../')
  if [[ "$CLASS" == "null" ]]; then
  echo "~"
  fi
  echo "$CLASS: $TITLE [+]"
  pkill -SIGRTMIN+8 waybar
}

niri-window() {
  TITLE=$(niri msg focused-window | awk -F'"' '/App ID/ { print $2 }' | tail -n1)
  echo "$TITLE [+]"
}

if [ "$XDG_SESSION_DESKTOP" = "Hyprland" ];then
  hyprland-window
elif [ "$XDG_SESSION_DESKTOP" = "niri" ];then
  niri-window
else
  echo "unknown session $SESSION_TYPE"
fi
