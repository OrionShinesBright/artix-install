#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

p::section "SELECT DISK"
echo -e "\nAvailable disks are:"
lsblk --noheadings --output PATH --nodeps
echo
read -rp "Which disk to install on: " DISK
[ -b "$DISK" ] || p::err "Invalid block device: $DISK"
export DISK
p::status "$DISK has been selected for installation"
p::ahead

p::section "DETECTING SYSTEM TYPE"
if [ -d /sys/firmware/efi/efivars/ ]; then
	export EFI=1
	export BOOT_SIZE="+512M"
	p::status "EFI System detected"
else
	export EFI=0
	p::status "BIOS System detected"
fi
p::ahead

p::section "CONFIRMING SWAP SIZE"
p::info "(Swap is virtual memory for your system)"
p::info "If you do not know what this means, then please write '0G'"
p::info "Syntax is XG, where X is the number of Gigabytes"
read -rp "How big should SWAP partition be [2G]: " SWAP_SIZE
SWAP_SIZE="${SWAP_SIZE:-2G}"
export SWAP_SIZE="+$SWAP_SIZE"
p::ahead

p::section "CONFIRMING HOSTNAME"
read -rp "What should your computer's name be [artix]: " HOSTNAME
HOSTNAME="${HOSTNAME:-artix}"
export HOSTNAME

p::section "CONFIRMING USERNAME"
read -rp "What should your user's name be [user]: " USERNAME
USERNAME="${USERNAME:-user}"
export USERNAME
p::ahead

p::section "CONFIRMING TIMEZONE"
p::info "(time zones are in the format: Region/City, e.g., Asia/Karachi or UTC)"
read -rp "What timezone to set [UTC]: " TIMEZONE
TIMEZONE="${TIMEZONE:-UTC}"
[ -f "/usr/share/zoneinfo/$TIMEZONE" ] || p::err "Invalid timezone: $TIMEZONE"
export TIMEZONE
p::ahead

p::section "SETTING LOCALE"
export LOCALE="en_US.UTF-8"
p::status "Locale set to $LOCALE"
p::ahead

p::section "INSTALLING TEXT EDITOR"
p::info "Many editors are available, notably: vim, and nano."
p::info "We shall be using vim"
pacman -Sy --needed --noconfirm vim
export EDITOR='vim'
sync
p::status "vim installed."
p::ahead

export PALANTIR="/home/$USERNAME/.palantir"

ENV_FILE="$SCRIPT_DIR/chroot-info/artix_env.sh"
cat >"$ENV_FILE" <<EOF
export DISK="$DISK"
export EFI="$EFI"
export HOSTNAME="$HOSTNAME"
export USERNAME="$USERNAME"
export TIMEZONE="$TIMEZONE"
export LOCALE="$LOCALE"
export EDITOR="$EDITOR"
export PALANTIR="/home/$USERNAME/.palantir"
EOF

p::status "All environment variables saved to $ENV_FILE"
p::status "You can load them later with:  source $ENV_FILE"
sync

p::ahead
