#!/bin/bash

p::section "USERSPACE SETUP"
p::info "Preparing home for ${USERNAME}..."
install -d -m 755 "/home/${USERNAME}/src" "/home/${USERNAME}/.config" "/home/${USERNAME}/pics"

p::info "Cloning and building suckless software..."
for repo in dwm dmenu st; do
    su -l "${USERNAME}" -c "
        mkdir -p ~/src &&
        cd ~/src &&
        [ -d ~/${repo} ] || git clone https://git.suckless.org/${repo}
    " || p::err "Could not clone ${repo}"
    cd "/home/${USERNAME}/src/${repo}" || continue
    make clean || true
    make PREFIX=/usr || p::err "Build failed for ${repo}"
    make PREFIX=/usr install || p::err "Install failed for ${repo}"
done

# --- Fix ownership ---
p::info "Fixing ownership for /home/${USERNAME}"
chown -R "${USERNAME}:${USERNAME}" "/home/${USERNAME}" || p::err "Could not chown home dir"

p::status "Userspace setup complete."
p::ahead
