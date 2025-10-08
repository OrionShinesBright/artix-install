#!/bin/bash

p::section "CHROOTING (CRITICAL)"
p::info "Entering chroot for detailed system configuration..."
echo
p::info "This part of the script will end once we ch(ange)root into the new system. It will take the next scripts, and place them into '/home/$USERNAME/.palantir'."
p::info "You should start The next part By running the command '/home/$USERNAME/.palantir/install.sh'"
echo
p::ahead
artix-chroot /mnt /bin/zsh
