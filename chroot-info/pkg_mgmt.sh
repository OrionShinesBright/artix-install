#!/bin/bash

p::section "Package Management"

p::info "Adding Arch mirrorlist and repository entries..."
pacman -Syu --needed --noconfirm pacman-contrib curl git base-devel || p::err "Failed to install core build tools"
sync

# --- Fetch and enable Arch mirrorlist ---
curl -fsSL 'https://archlinux.org/mirrorlist/all/' -o /etc/pacman.d/mirrorlist-arch || p::err "Could not fetch Arch mirrorlist"
sync
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist-arch || p::err "Mirrorlist un-commenting failed"

# --- Rank mirrors safely ---
p::info "Ranking top mirrors (this may take a bit)..."
rankmirrors -n 6 /etc/pacman.d/mirrorlist-arch > /etc/pacman.d/mirrorlist-arch.ranked || p::err "Mirror ranking failed"
mv -f /etc/pacman.d/mirrorlist-arch.ranked /etc/pacman.d/mirrorlist-arch || true
sync

# --- Inject Arch repo (if not already present) ---
if ! grep -q '^\[extra\]' /etc/pacman.conf; then
cat >> /etc/pacman.conf <<'EOF'

# --- Arch Linux repo ---
[extra]
Include = /etc/pacman.d/mirrorlist-arch
EOF
p::status "Added Arch Linux [extra] repo to pacman.conf"
else
  echo "[extra] repo already present in pacman.conf"
fi

# --- Refresh keys and sync ---
p::info "Initializing pacman keyring..."
pacman-key --init || p::err "pacman-key init failed (may already exist)"
pacman-key --populate || p::err "pacman-key populate failed"
pacman -Syyu --noconfirm || p::err "Final system update failed"

# --- Build yay-bin as user ---
p::info "Building yay-bin (AUR helper) as ${USERNAME}..."
su -l "${USERNAME}" -c '
  cd ~ &&
  rm -rf yay-bin &&
  git clone https://aur.archlinux.org/yay-bin.git &&
  cd yay-bin &&
  makepkg -si --noconfirm
' || p::err "Failed to build yay-bin"

# --- Clean up yay-bin clone ---
rm -rf "/home/${USERNAME}/yay-bin" || true
sync

# --- Configure makepkg (user-level) ---
p::info "Configuring makepkg for ${USERNAME}..."
mkdir -p "/home/${USERNAME}/.config/pacman" || p::err "Failed to create pacman config dir"
cat > "/home/${USERNAME}/.config/pacman/makepkg.conf" <<'EOF'
MAKEFLAGS="--jobs=8"
OPTIONS=(!debug !lto)
EOF
p::status "makepkg configuration complete."

p::info "Fixing ownership for ${USERNAME}'s home directory..."
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}" || p::err "Could not fully chown /home/${USERNAME}"
p::ahead
