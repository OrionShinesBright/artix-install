#!/bin/bash

p::section "BASESTRAPPING"
p::info "The artix-linux-base ISO does not have many programs by default."
p::info "It takes programs from the artix-repositories and installs them to the new system"
p::info "Beginning basestrap:"
baseStrapping() {
	basestrap -iK /mnt \
		base base-devel \
		runit elogind-runit \
		linux linux-firmware-intel linux-headers \
		sof-firmware \
		grub efibootmgr \
		networkmanager networkmanager-runit \
		intel-ucode \
		vim git \
		zsh zsh-completions \
		chrony chrony-runit || return 1
}

attempts=0
max_attempts=3
until baseStrapping; do
	attempts=$((attempts + 1))
	if [ "$attempts" -ge "$max_attempts" ]; then
		p::err "Basestrap failed after $attempts attempts"
	fi
	p::info "Basestrap failed — retrying ($attempts/$max_attempts) in 3s"
	sleep $((2 + RANDOM % 3))
done
p::status "Basestrap has succeeded."
