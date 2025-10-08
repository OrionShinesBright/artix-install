#!/bin/bash

# --- Allow the user to edit pacman.conf in chroot ---
p::section "CONFIGURE PACMAN [2]"
p::info "Edit /etc/pacman.conf to adjust pacman ($EDITOR will open)"
sleep 1
vim /etc/pacman.conf || true
p::status "Edited /etc/pacman.conf"
p::ahead
