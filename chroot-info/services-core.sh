#!/bin/bash
p::section "CORE SERVICES"

p::info "Installing DBus, Cron, and Bluetooth stacks..."
pacman -S --needed --noconfirm dbus dbus-runit bluez bluez-utils bluez-runit cronie cronie-runit || p::err "Base service install failed"

for svc in dbus bluetoothd cronie; do
    [ -d "/etc/runit/sv/$svc" ] && ln -sf "/etc/runit/sv/$svc" /etc/runit/runsvdir/default/
done

p::info "Ensuring audio group and realtime limits..."
groupadd -f audio
usermod -aG audio "$USERNAME"
grep -q '@audio' /etc/security/limits.conf || cat >> /etc/security/limits.conf <<'EOF'
@audio   -  rtprio     95
@audio   -  memlock    unlimited
EOF

p::status "Core system services configured."
p::ahead
