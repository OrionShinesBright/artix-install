#!/bin/bash

p::section "CORE SERVICES"
p::info "Installing dbus, cron, and bluetooth"
pacman -S --needed --noconfirm dbus dbus-runit bluez bluez-utils bluez-runit cronie cronie-runit || p::err "Core services install failed"
sync
p::status "Installation completed"

p::info "Linking services to runit"
for svc in dbus bluetoothd cronie; do
    [ -d "/etc/runit/sv/$svc" ] && ln -sf "/etc/runit/sv/$svc" /etc/runit/runsvdir/default/
    p::status "Linked $svc"
done

p::status "Core system services configured."
p::ahead
