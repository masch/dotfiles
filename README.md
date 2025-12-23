<p align="center">
  <img src="assets/tux.png" width="100" alt="Tux Logo">
</p>

# Dotfiles

A collection of useful scripts for GNOME and Linux system management.

## Scripts

### [add-location-to-gnome-weather.sh](bin/add-location-to-gnome-weather.sh)
Search and add locations to GNOME Weather using OpenStreetMap Nominatim API. Works with both system-installed and Flatpak versions.

### [check-batery-charge.sh](bin/check-batery-charge.sh)
Monitor battery level and send a notification when it reaches 95%, reminding you to unplug the charger.

### [laptop-lid-open.sh](bin/laptop-lid-open.sh)
Triggered when the laptop lid is opened to automatically disable the hotspot (via `toggle-hotspot.sh off`).

### [notify.sh](bin/notify.sh)
A demo script showing how to send and replace persistent GNOME notifications via `gdbus`.

### [toggle-caffine.sh](bin/toggle-caffine.sh)
Toggle "Caffeine" mode using `gnome-session-inhibit` to prevent the system from sleeping or going idle.

### [toggle-do-not-disturb.sh](bin/toggle-do-not-disturb.sh)
Toggle GNOME "Do Not Disturb" (banners) mode.

### [toggle-hotspot.sh](bin/toggle-hotspot.sh)
Advanced Wi-Fi hotspot management. Features:
- Client connection verification (auto-shuts down if no clients are connected).
- Wired speed monitoring (notifies if speed is not the expected 10Mbps).
- Supports `on`, `off`, `status`, and `toggle` (default) commands.

### [toggle-net-10mbs.sh](bin/toggle-net-10mbs.sh)
Toggle wired network speed between "Auto" and forced "10Mbps". Useful for specific network testing or power saving. Requires `sudo`.

## Requirements
To use all features of these scripts, ensure the following are installed:
- `gnome-weather` (optional, for weather script)
- `nmcli` (NetworkManager)
- `gdbus` (GLib)
- `bc` (Arbitrary precision calculator)
- `ethtool` (Ethernet tool)
- `rfkill` (RF kill tool)

## Usage
Add the `bin` directory to your `$PATH` in your shell configuration (e.g., `.bashrc` or `.zshrc`):
```bash
export PATH="$HOME/dev/linux/dotfiles/bin:$PATH"
```
