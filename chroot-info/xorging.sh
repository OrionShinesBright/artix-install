#!/bin/bash

p::section "XORGING AWAY"
p::info "Installing Xorg, mesa, input drivers, compositor, fonts, and tools..."
xorging() {
	pacman -S --noconfirm --needed \
		xorg xorg-server \
		xorg-apps xorg-xinit xorg-xrandr xorg-xsetroot xorg-server-xephyr \
    	xorg-drivers mesa vulkan-intel xf86-video-intel xf86-input-libinput\
    	feh nsxiv picom \
    	make xdg-user-dirs cups \
    	ttf-liberation ttf-font-awesome ttf-jetbrains-mono-nerd ttf-hack-nerd ttf-noto-fonts-emoji || ( p::info "Retrying xorging" && xorging )
}
xorging
p::status "Xorged away"
p::ahead
