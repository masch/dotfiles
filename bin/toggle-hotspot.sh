#!/bin/bash

CONNECTION_NAME="Hotspot"
WIFI_INTERFACE="wlp0s20f3"       # Explicitly Wi-Fi interface
WIRED_SPEED_EXPECTED="10Mb/s"
CHECK_INTERVAL_WIRED_SPEED_EXPECTED=60
CHECK_INTERVAL_ACTIVE_HOTSPOT_CLIENT_CONNECTION=2*60
APP_NAME="Abundancia Netwok"
ICON_NAME="dialog-information"
EXPIRE_TIMEOUT=5000
STATE_FILE="/tmp/abundancia-network.id"

###################
# Send notification
###################
send_notification() {
    local summary="$1"
    local body="$2"

    local replaces_id=0
    if [[ -f "$STATE_FILE" && "$(cat "$STATE_FILE")" =~ ^[0-9]+$ ]]; then
        replaces_id=$(cat "$STATE_FILE")
    fi

    echo "$summary" - "$body"
    local response=$(gdbus call --session \
        --dest org.freedesktop.Notifications \
        --object-path /org/freedesktop/Notifications \
        --method org.freedesktop.Notifications.Notify \
        "$APP_NAME" "$replaces_id" "$ICON_NAME" "$summary" "$body" [] {} $EXPIRE_TIMEOUT)

    local new_id=$(echo "$response" | awk '{print $2}' | tr -d ',)')
    echo "$new_id" > "$STATE_FILE"
}

########################
# Get active wired iface
########################
get_active_wired_interface() {
  for iface in /sys/class/net/*; do
    IFNAME=$(basename "$iface")
    [[ "$IFNAME" == "lo" || -d "$iface/wireless" ]] && continue
    LINK=$(ethtool "$IFNAME" 2>/dev/null | grep "Link detected" | awk '{print $3}')
    if [[ "$LINK" == "yes" ]]; then
      echo "$IFNAME"
      return 0
    fi
  done
  return 1
}

########################################################
# Validate is wired network speed is working as expected
########################################################
validate_wired_network_speed() {
  local LOG_ENABLED=${1:-false} 
  local ACTIVE_WIRED_IFACE
  local SPEED
  local MESSAGE

  # Get active wired interface
  ACTIVE_WIRED_IFACE=$(get_active_wired_interface)

  # Get speed information using ethtool
  SPEED=$(ethtool "$ACTIVE_WIRED_IFACE" 2>/dev/null | grep -i "Speed:" | awk '{print $2}')

  # Check if the speed is not the expected value
  if [[ "$SPEED" != "$WIRED_SPEED_EXPECTED" ]]; then
    MESSAGE="Network speed on $ACTIVE_WIRED_IFACE is not $WIRED_SPEED_EXPECTED, it is: $SPEED"

    if [[ "$LOG_ENABLED" == "true" ]]; then
      #echo "$MESSAGE"
      send_notification "📶 Network speed error" "$MESSAGE"
    fi

    return 1
  fi

  return 0
}

######################
# Enable airplane mode
######################
enable_airplane_mode() {
  send_notification "⏳ Setting airplane mode ..."
  rfkill block all
  MESSAGE="Airplane mode activated"
  #echo $MESSAGE 
  send_notification "✈️  $MESSAGE"
}

########################
# Start wifi and hotspot
########################
start_wifi_hotspot() {
  #echo "Starting wifi..."
  send_notification "⏳ Starting hotspot ..."
  rfkill unblock wlan
  sleep 1
  #send_notification "Starting networking..."
  nmcli networking on
  #send_notification "Networking started"
  #send_notification "Starting Hotspot on interface $WIFI_INTERFACE..."
  nmcli radio wifi on
  nmcli con up "$CONNECTION_NAME" ifname "$WIFI_INTERFACE"
  #echo "Hotspot started"
  send_notification "🛜 Hotspot started"
}

#############################
# Check connected clients
#############################
check_connected_clients() {
  if [ -z "$(iw dev "$WIFI_INTERFACE" station dump)" ]; then
    send_notification "Hotspot Status" "No clients connected to $CONNECTION_NAME."
    return 1
  else
    #send_notification "Hotspot Status" "Clients connected to $CONNECTION_NAME."
    #iw dev "$WIFI_INTERFACE" station dump
    return 0
  fi
}

#################################
# Start hotspot and verify clients
#################################
start_hotspot_and_verify() {
  send_notification "Hotspot Verification" "Starting hotspot and continuously verifying client connection..."
  start_wifi_hotspot
  sleep 120 # Initial wait for clients to connect

  while true; do
    if ! check_connected_clients; then
      send_notification "Hotspot Verification" "No clients connected. Enabling airplane mode."
      enable_airplane_mode
      break
    else
     # send_notification "Hotspot Verification" "Clients connected. Hotspot active."
     echo "Clients connected. Hotspot active."
    fi
    sleep "$CHECK_INTERVAL_ACTIVE_HOTSPOT_CLIENT_CONNECTION"
  done
}

#######################
# Toggle hostpost state
####################### 
toggle_hotspot() {
  current_connection=$(nmcli dev status | grep "^$WIFI_INTERFACE" | awk '{print $4}')
  cleaned_connection=$(echo "$current_connection" | tr -d '\n')

  if [ "$cleaned_connection" == "$CONNECTION_NAME" ]; then
    enable_airplane_mode
  else
    start_hotspot_and_verify
  fi
}

############################################
# Exit if there is no active wired interface
############################################
# Get active wired interface
ACTIVE_WIRED_IFACE=$(get_active_wired_interface)

echo $ACTIVE_WIRED_IFACE
if [[ "$ACTIVE_WIRED_IFACE" == "" ]]; then
   send_notification "Wired Verification" "No wired connection."
   exit
fi

case "$1" in
  off)
    enable_airplane_mode
    ;; 
  on)
    start_hotspot_and_verify
    ;; 
  status)
    check_connected_clients
    ;; 
  verify)
    check_connected_clients
    ;; 
  *)
    toggle_hotspot
    ;; 
esac

#################################
# Loop until speed is as expected
#################################
if ! validate_wired_network_speed; then
  while true; do
    sleep $CHECK_INTERVAL_WIRED_SPEED_EXPECTED
    if validate_wired_network_speed true; then
      break  # Exit the loop and script when speed is OK
    fi
  done
fi
