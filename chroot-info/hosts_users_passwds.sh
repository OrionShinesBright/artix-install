#!/bin/bash

p::section "HOSTS, USERS, and PASSWORDS"
p::info "Configuring hostname..."
echo "${HOSTNAME}" > /etc/hostname || p::err "Failed to write /etc/hostname"
cat > /etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
EOF
p::status "Hostname and hosts configured."
sync

# --- Users & passwords ---
p::info "Creating user '${USERNAME}' (if not exists):"
if ! id -u "${USERNAME}" >/dev/null 2>&1; then
  useradd -m -G wheel,audio,video,storage -s /bin/zsh "${USERNAME}" || p::err "Failed to create user ${USERNAME}"
  p::status "User ${USERNAME} created."
else
  echo  "User ${USERNAME} already exists, skipping creation."
fi

p::info "Set root password now:"
passwd || p::err "Failed to set root password"
p::status "Root passwd set"

p::info "Set password for user ${USERNAME}:"
passwd "${USERNAME}" || p::err "Failed to set password for ${USERNAME}"
p::status "${USERNAME} passwd set"

if ! command -v sudo >/dev/null 2>&1; then
  p::info "Installing sudo"
  pacman -Sy --noconfirm --needed sudo vim || p::err "Failed to install sudo"
  p::status "Installed sudo"
fi

p::info "Opening visudo (vim will open)."
EDITOR=vim visudo || p::err "visudo exited with non-zero status"
p::status "visudo file edited successfully"
sync

p::status "User and password configuration complete."
p::ahead
