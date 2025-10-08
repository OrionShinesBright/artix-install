#!/bin/bash

p::section "CHROOT PREPARATION"
p::info "Copying over the files needed to perform chroot operations, to /home/$USERNAME/.palantir"
p::info "These scripts will be used later to configure your system"

p::info "Creating /mnt/home/$USERNAME"
mkdir -p "/mnt/home/$USERNAME" || p::err "Could not create /mnt/home/$USERNAME"

pacman -S --noconfirm --needed rsync

p::info "Copying dotfiles to new home (preserving attributes)"
rsync -a --no-owner --no-group "$SCRIPT_DIR/HOME/" "/mnt/home/$USERNAME/" || p::err "Could not copy dotfiles to chroot"

p::info "Copying chroot scripts to $PALANTIR inside chroot"
mkdir -p "/mnt${PALANTIR}" || p::err "Could not create /mnt${PALANTIR}"
rsync -a "$SCRIPT_DIR/chroot-info/" "/mnt${PALANTIR}/" || p::err "Could not copy part 2 of install script to chroot!"

chmod +x "/mnt${PALANTIR}/install.sh"

p::ahead
