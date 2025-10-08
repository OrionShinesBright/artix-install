#!/bin/bash

p::section "BOOTLOADER SETUP"

[ -z "$EFI" ] && p::err "EFI variable not set — internal error"
[ -z "$DISK" ] && p::err "DISK variable not set — internal error"

if [ "$EFI" = "1" ]; then
    p::info "Detected EFI system — installing GRUB for UEFI..."
    grub-install \
        --target=x86_64-efi \
        --efi-directory=/boot/efi \
        --bootloader-id=grub || p::err "GRUB EFI install failed"
else
    p::info "Detected BIOS system — installing GRUB for legacy boot..."
    grub-install \
        --target=i386-pc \
        "$DISK" \
        --recheck || p::err "GRUB BIOS install failed"
fi
p::status "GRUB has been installed"

p::info "Generating configuation for GRUB"
grub-mkconfig -o /boot/grub/grub.cfg || p::err "Failed to generate GRUB config"
p::status "Configuration complete."
p::ahead
