#!/bin/bash

p::section "FINALIZATION"
p::info "Starting essential services (if runit is live)..."
for svc in NetworkManager chronyd dbus greetd bluetoothd cronie; do
    sv up "$svc" 2>/dev/null || true
done

p::info "Syncing, unmounting, and powering down..."
sync
umount -a || true
swapoff -a || true

p::status "Installation complete — rebooting in 5 seconds..."
sleep 5
reboot
