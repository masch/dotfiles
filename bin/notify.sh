#!/bin/bash

APP_NAME="My Bash App"
ICON_NAME="dialog-information"
EXPIRE_TIMEOUT=5000
STATE_FILE="/tmp/mybashapp.id"

send_notification() {
    local summary="$1"
    local body="$2"

    local replaces_id=0
    if [[ -f "$STATE_FILE" && "$(cat "$STATE_FILE")" =~ ^[0-9]+$ ]]; then
        replaces_id=$(cat "$STATE_FILE")
    fi

    local response=$(gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "$APP_NAME" "$replaces_id" "$ICON_NAME" "$summary" "$body" [] {} $EXPIRE_TIMEOUT)

    local new_id=$(echo "$response" | awk '{print $2}' | tr -d ',)')
    echo "$new_id" > "$STATE_FILE"
}

# Demo
send_notification "Step 1" "Preparing"
sleep 10
send_notification "Step 2" "Doing work"
sleep 10
send_notification "Done" "Finished!"

