#!/bin/bash

p::section "TIMEZONE AND LOCALE"
p::info "Setting timezone to ${TIMEZONE}..."
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime || p::err "Failed to set timezone"
hwclock --systohc || p::err "Failed to sync hardware clock"

p::info "Enabling locale ${LOCALE}..."
sed -i "s|^#\(${LOCALE} UTF-8\)|\1|" /etc/locale.gen || p::warn "Could not uncomment ${LOCALE} in locale.gen"
locale-gen || p::err "locale-gen failed"

# Write /etc/locale.conf atomically
cat > /etc/locale.conf <<EOF
LANG=${LOCALE}
LC_COLLATE=C
EOF

p::status "Locale and timezone configured successfully."
p::ahead
