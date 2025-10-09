#!/bin/bash

p::section "CONFIGURE PACMAN [2]"
p::info "Edit /etc/pacman.conf to adjust pacman ($EDITOR will open)"
p::ahead
vim /etc/pacman.conf || p::err "Failed to open /etc/pacman.conf"
p::status "Edited /etc/pacman.conf"
sync
p::ahead
