#!/bin/bash

PID_FILE="$HOME/.local/share/caffeine-session.pid"

# Check if it's already running
if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if ps -p "$PID" > /dev/null 2>&1; then
    echo "Caffeine mode OFF. Killing process $PID."
    kill "$PID"
    rm "$PID_FILE"
    exit 0
  else
    echo "Stale PID file found. Removing."
    rm "$PID_FILE"
  fi
fi

# Start caffeine session
echo "Caffeine mode ON."
gnome-session-inhibit --inhibit suspend --inhibit idle sleep infinity &
echo $! > "$PID_FILE"
