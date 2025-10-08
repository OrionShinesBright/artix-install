#!/bin/bash

p::section "USER CONFIG FILES"

p::info "Setting up picom config..."
install -d -m 755 "/home/${USERNAME}/.config/picom"
install -m 644 "$SCRIPT_DIR/HOME/.config/userspace/picom.conf" "/home/${USERNAME}/.config/picom/picom.conf"

p::info "Installing redshift + geoclue..."
pacman -S --needed --noconfirm redshift geoclue
cat > /etc/geoclue/geoclue.conf <<'EOF'
[redshift]
allowed=true
system=false
users=
EOF

p::info "Setting wallpaper if provided..."
install -d -m 755 "/home/${USERNAME}/pics"
if [ -f "$WALLPAPER_SRC" ]; then
    cp "$WALLPAPER_SRC" "/home/${USERNAME}/pics/wallpaper.jpg"
fi

chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}"
p::status "User visual configuration ready."
p::ahead
