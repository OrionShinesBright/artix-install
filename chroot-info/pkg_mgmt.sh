#!/bin/bash

p::section "Package Management"

p::info "Installing pacman-contrib"
pacman -Syu --needed --noconfirm pacman-contrib curl || p::err "Failed to install pacman-contrib and/or curl"
sync
p::status "Pacman-contrib installed"

p::info "Adding Arch mirrorlist and repository entries"
curl -fsSL 'https://archlinux.org/mirrorlist/all/' -o /etc/pacman.d/mirrorlist-arch || p::err "Could not fetch Arch mirrorlist"
sync
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist-arch || p::err "Mirrorlist un-commenting failed"
p::status "Mirrorlist updated"

p::info "Ranking top mirrors (this may take a bit of time)"
rankmirrors -n 10 /etc/pacman.d/mirrorlist-arch >/etc/pacman.d/mirrorlist-arch.ranked || p::err "Mirror ranking failed"
mv -f /etc/pacman.d/mirrorlist-arch.ranked /etc/pacman.d/mirrorlist-arch || p::err "Mirrorlist movement failed"
sync
p::status "Ranked mirrors."

p::info "Adding Arch Linux's [extra] repo"
if ! grep -q '^\[extra\]' /etc/pacman.conf; then
	cat >>/etc/pacman.conf <<'EOF'

# --- Arch Linux repo ---
[extra]
Include = /etc/pacman.d/mirrorlist-arch
EOF
	p::status "Added Arch Linux [extra] repo to pacman.conf"
else
	p::status "[extra] repo already present in pacman.conf"
fi
sync

p::info "Initializing pacman keyring..."
pacman-key --init || p::err "pacman-key init failed (may already exist)"
pacman-key --populate || p::err "pacman-key populate failed"
pacman -Syyu --noconfirm || p::err "Final system update failed"
sync
p::status "Keyring managed"

p::info "Building yay-bin (AUR helper) as ${USERNAME}"
su -l "${USERNAME}" -c '
  cd ~ &&
  rm -rf yay-bin &&
  git clone https://aur.archlinux.org/yay-bin.git &&
  cd yay-bin &&
  makepkg -si --noconfirm
' || p::err "Failed to build yay-bin"
rm -rf "/home/${USERNAME}/yay-bin" || true
sync
p::status "Yay built"

p::ahead
