#!/bin/bash

# Configuration
CONN_NAME="Wired connection 1"

# 1. Get the Interface Name (e.g., enp0s20f0u2u1u1) automatically
DEVICE=$(nmcli -g GENERAL.DEVICES connection show "$CONN_NAME")

# 2. Get Configured Status (What NetworkManager "wants" to do)
CONFIG_STATE=$(nmcli -g 802-3-ethernet.auto-negotiate connection show "$CONN_NAME")

# --- FUNCTION: Show Status ---
show_status() {

    # Ensure the script is run as root
    if [ "$EUID" -ne 0 ]; then
       echo "Please run as root (use sudo)"
       exit 1
    fi

    echo "========================================"
    echo "CONNECTION:  $CONN_NAME"
    echo "INTERFACE:   $DEVICE"
    echo "----------------------------------------"
    
    # Check what was configured in NetworkManager
    if [ "$CONFIG_STATE" = "no" ]; then
        echo "CONFIG MODE: FORCED 10Mbps (Auto-neg OFF)"
    else
        echo "CONFIG MODE: AUTO (Normal)"
    fi

    # Check actual hardware reality using ethtool
    echo "----------------------------------------"
    echo "ACTUAL HARDWARE SPEED:"
    if command -v ethtool &> /dev/null; then
        ethtool "$DEVICE" | grep -E "Speed:|Duplex:|Auto-negotiation:"
    else
        echo " (ethtool not found, cannot read hardware stats)"
    fi
    echo "========================================"
}

# --- MAIN LOGIC ---

# If the user passed "status" as a parameter, just show info and exit
if [ "$1" == "status" ]; then
    show_status
    exit 0
fi

# Otherwise, TOGGLE the setting
echo "Toggling network speed..."

if [ "$CONFIG_STATE" = "no" ]; then
    echo ">> Switching back to: AUTO (Max Speed)"
    nmcli connection modify "$CONN_NAME" 802-3-ethernet.auto-negotiate yes
else
    echo ">> Switching to: FORCED 10Mbps"
    nmcli connection modify "$CONN_NAME" 802-3-ethernet.auto-negotiate no 802-3-ethernet.speed 10 802-3-ethernet.duplex full
fi

# Apply changes
nmcli connection up "$CONN_NAME" > /dev/null 2>&1
echo "Done."

