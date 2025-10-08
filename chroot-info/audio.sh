#!/bin/bash

p::section "PIPEWIRE STACK"
pacman -S --needed --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber || p::err "PipeWire install failed"
p::status "PipeWire, WirePlumber, and audio routing configured."
p::ahead
