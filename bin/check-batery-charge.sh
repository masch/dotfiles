#!/bin/bash

BATTERY_PATH="/sys/class/power_supply/BAT0/capacity"

# Make sure battery info exists
if [ ! -f "$BATTERY_PATH" ]; then
    echo "Battery info not found at $BATTERY_PATH"
    exit 1
fi

LAST_PERCENTAGE=""

while true; do
    PERCENTAGE=$(cat "$BATTERY_PATH")
    
    if [ "$PERCENTAGE" != "$LAST_PERCENTAGE" ]; then
        CURRENT_TIME=$(date +%Y-%m-%d\ %H:%M)
        echo "$CURRENT_TIME - Battery is at ${PERCENTAGE}%"
        LAST_PERCENTAGE="$PERCENTAGE"
    fi


    if [ "$PERCENTAGE" -ge 95 ]; then
        notify-send "🔋 Battery Alert" "Battery reached ${PERCENTAGE}%. You can unplug the charger."
        break
    fi

    sleep 60
done

