#!/bin/bash
set -euo pipefail

p::section "DISK PARTITIONING"
[ -z "${DISK:-}" ] && p::err "DISK variable not set"

p::info "Wiping partitions on $DISK and creating GPT layout..."
wipefs -af "$DISK"
sync
p::status "Wiped."

p::info "Installing gptfdisk and parted"
pacman -S --noconfirm --needed gptfdisk parted || p::err "parted could not be installed"
p::status "Installed."

sgdisk --zap-all "$DISK"
sync

# Prepare partition spec depending on whether swap requested
if [ "${EFI:-0}" -eq 1 ]; then
	p::info "Creating EFI layout"
	if [ -n "${SWAP_SIZE:-}" ] && [ "$SWAP_SIZE" != "0" ]; then
		sgdisk -n1:0:"$BOOT_SIZE" -t1:ef00 -c1:"EFI System" \
			-n2:0:"$SWAP_SIZE" -t2:8200 -c2:"Linux swap" \
			-n3:0:0 -t3:8300 -c3:"Linux filesystem" \
			"$DISK"
		p::status "Three partitions created (EFI, SWAP, ROOT)"
	else
		sgdisk -n1:0:"$BOOT_SIZE" -t1:ef00 -c1:"EFI System" \
			-n2:0:0 -t2:8300 -c2:"Linux filesystem" \
			"$DISK"
		p::status "Two partitions created (EFI,ROOT)"
	fi
else
	p::info "Creating BIOS layout"
	if [ -n "${SWAP_SIZE:-}" ] && [ "$SWAP_SIZE" != "0" ]; then
		sgdisk -n1:0:"$SWAP_SIZE" -t1:8200 -c1:"Linux swap" \
			-n2:0:0 -t2:8300 -c2:"Linux filesystem" \
			"$DISK"
		p::status "Two partitions created (SWAP,ROOT)"
	else
		sgdisk -n1:0:0 -t1:8300 -c1:"Linux filesystem" "$DISK"
		p::status "One partition created (ROOT)"
	fi
fi

sync
partprobe "$DISK"
sleep 1

if [ "$EFI" == 1 ]; then
	case "$DISK" in
	*nvme*)
		BOOT="${DISK}p1"
		SWAP="${DISK}p2"
		ROOT="${DISK}p3"
		;;
	*)
		BOOT="${DISK}1"
		SWAP="${DISK}2"
		ROOT="${DISK}3"
		;;
	esac
else
	case "$DISK" in
	*nvme*)
		SWAP="${DISK}p1"
		ROOT="${DISK}p2"
		;;
	*)
		SWAP="${DISK}1"
		ROOT="${DISK}2"
		;;
	esac
fi

p::section "DISK FORMATTING"
if [ "$EFI" == 1 ]; then
	p::info "Formatting BOOT..."
	mkfs.fat -F32 -n BOOT "$BOOT" || p::err "Could not format BOOT"
	p::status "BOOT formatted as fat-32"
fi
if [ "$SWAP_SIZE" != "0" ]; then
	p::info "Creating SWAP..."
	mkswap -L SWAP "$SWAP" || p::err "Could not create SWAP"
	p::status "SWAP created"
fi
p::info "Formatting ROOT..."
mkfs.ext4 -L ROOT "$ROOT" || p::err "Could not format ROOT"
p::status "ROOT formatted as ext4"
sync

p::section "DISK MOUNTING"
p::info "Unmounting previous mounts, and turning off old swap"
if mountpoint -q /mnt; then
	p::info "Unmounting any existing mounts under /mnt"
	umount -R /mnt || true
fi
if swapon --noheadings --summary | grep -q .; then
	p::info "Turning off all swap devices"
	swapoff --all || p::err "Failed to turn off swap"
fi

if [ "$SWAP_SIZE" != "0" ]; then
	p::info "Turning new SWAP on"
	swapon "$SWAP" || p::err "SWAP could not be started"
	p::status "SWAP is on"
fi
p::info "Mounting ROOT at /mnt"
mount "$ROOT" /mnt || p::err "ROOT could not be mount at /mnt"
p::status "ROOT is mounted at /mnt"
if [ "$EFI" == 1 ]; then
	p::info "Mounting BOOT at /mnt/boot/efi"
	mkdir -p /mnt/boot/efi || p::err "mkdir failed at creating /mnt/boot/efi"
	sync
	mount "$BOOT" /mnt/boot/efi || p::err "BOOT could not be mounted"
	p::status "BOOT mounted at /mnt/boot/efi"
fi
sync
