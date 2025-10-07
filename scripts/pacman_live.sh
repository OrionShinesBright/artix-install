#!/bin/bash

p::section "Configure Pacman [1]"
p::info "Package management requires system time to be functional"
p::info "Setting up the chronyd service to correct the live system's time"
pacman -Sy --needed chrony chrony-runit || p::info "Chronyd could not be installed!!!!!"
chronyd -q 'server time.cloudflare.com iburst' || true
sync

echo -e "\n\n"

p::info "It is common to want to speed up installation processes by editing a config file"
read -rp "Edit /etc/pacman.conf? (y/N): " ans
( [[ "$ans" =~ ^[Yy]$ ]] && "$EDITOR" /etc/pacman.conf ) || p::err "Could not open $EDITOR"
p::status "File edited"
sync
p::ahead
