#!/bin/bash
p::section "LOGIN MANAGER (greetd + tuigreet)"

pacman -S --needed --noconfirm greetd greetd-runit greetd-tuigreet || p::err "Failed to install greetd"

mkdir -p /etc/greetd
cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd startx"
user = "${USERNAME}"
EOF

ln -sf /etc/runit/sv/greetd /etc/runit/runsvdir/default/
p::status "greetd configured and enabled."
