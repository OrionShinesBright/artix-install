#!/bin/bash

p::section "BASESTRAPPING"
p::info "The artix-linux-base ISO does not have many programs by default."
p::info "It takes programs from the artix-repositories and installs them to the new system"
p::info "Beginning basestrap:"
baseStrapping () {
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
		chrony chrony-runit || ( baseStrapping && p::info "Rerunning basestrap after failure" )
}
baseStrapping
p::status "Basestrap has succeeded."
