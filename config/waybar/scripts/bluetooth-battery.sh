#!/bin/sh

main() {
  device=$(echo 'info' | bluetoothctl | grep 'Name' | awk '{$1=""; sub(/^ /, ""); print}')
  dev_battery=$(echo "info" | bluetoothctl | sed -n '/Battery Percentage:/ s/.*(\([0-9]*\).*/\1/p')
  echo "$device: $dev_battery%"
}

if echo "info" | bluetoothctl | grep -q "Missing"; then
    exit 1
else
    main
fi
