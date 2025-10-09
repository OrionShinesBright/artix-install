#!/bin/bash

p::section "FINALIZATION"

p::info "Fixing ownership for ${USERNAME}'s home directory..."
chmod +x /home/"${USERNAME}"/post-install.sh
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}" || p::err "Could not fully chown /home/${USERNAME}"
sync
p::status "Chown worked."


p::info "Syncing, unmounting, and powering down..."
sync
umount -a || true
swapoff -a || true
p::status "Almost there"
sync

p::status "Installation complete :D"
p::status "Well done. Reboot now."
p::ahead
exit
