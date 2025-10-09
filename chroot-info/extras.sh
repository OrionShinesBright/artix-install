#!/bin/bash

p::section "EXTRA UTILITIES"
pacman -S --needed --noconfirm fzf neovim firefox pavucontrol easyeffects helvum || echo "Some extras failed to install"
p::status "Extra desktop utilities installed."
p::ahead
