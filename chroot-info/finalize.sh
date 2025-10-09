#!/bin/bash

p::section "FINALIZATION"
p::info "Starting essential services (if runit is live)..."
for svc in NetworkManager chronyd dbus greetd bluetoothd cronie; do
    sv up "$svc" 2>/dev/null || p::err "Error upping $svc runit links via sv"
    p::status "Upped the runit link: $svc."
    sync
done

p::info "Fixing ownership for ${USERNAME}'s home directory..."
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}" || p::err "Could not fully chown /home/${USERNAME}"
sync
p::status "Chown worked."

p::info "Syncing, unmounting, and powering down..."
sync
umount -a || true
swapoff -a || true
p::status "Almost there"
pacman -Syyu --needed --noconfirm
sync
( [ -d /home/"${USERNAME}"/.palantir ] && [ -d /home/"${USERNAME}"/.config ] && p::status "Flawless." ) || p::err "~/.palantir or ~/.config is missing"

p::status "Installation complete — rebooting now."
p::ahead
p::status "Well done."
p::ahead
reboot
