#!/bin/bash

p::section "TIMEZONE AND LOCALE"
p::info "Setting timezone to ${TIMEZONE}..."
ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime || p::err "Failed to set timezone"
sync
p::status "Timezone successfully set"

p::info "Syncing hardware clock"
hwclock --systohc || p::err "Failed to sync hardware clock"
sync
p::status "Synced"

p::info "Enabling locale ${LOCALE}..."
sed -i "s|^#\(${LOCALE} UTF-8\)|\1|" /etc/locale.gen || p::err "Could not uncomment ${LOCALE} in locale.gen"
sync
locale-gen || p::err "locale-gen failed"
sync
p::status "Locale generated"

p::info "Locale.conf is being generated"
cat > /etc/locale.conf <<EOF
LANG=${LOCALE}
LC_COLLATE=C
EOF
sync
p::status "Generated"
echo
p::status "Locale and timezone configured successfully."
p::ahead
