#!/bin/bash

p::section "Validating Environment Conditions"

# Check if Root
if [ "$(id -u)" -ne 0 ]; then
	p::err "Run this as root from the Artix live ISO root shell."
else
	p::status "Running as root [1/2]"
fi

# Check for internet connection
rfkill unblock all || true
ip link set wlan0 up 2>/dev/null || true
if ! ping -c 3 -W 2 artixlinux.org >/dev/null 2>&1; then
	p::err "No network detected. Connect (ethernet, nmcli, or phone tether) and rerun."
else
	p::status "Connected to the internet [2/2]"
fi
