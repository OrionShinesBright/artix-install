#!/bin/bash

p::section "USERSPACE SETUP"
p::info "Preparing home for ${USERNAME}..."
install -d -m 755 "/home/${USERNAME}/src" "/home/${USERNAME}/.config" "/home/${USERNAME}/pics"
sync
p::status "HOME is ready"

p::info "Getting necessary libs for dwm"
pacman -S libxft libxinerama || p::err "Could not install libxft + libxinerama"
sync
p::status "Installed"

p::info "Cloning and building suckless software..."
for repo in dwm dmenu st; do
    su -l "${USERNAME}" -c "
        mkdir -p ~/src &&
        cd ~/src &&
        [ -d ~/${repo} ] || git clone https://git.suckless.org/${repo}
    " || p::err "Could not clone ${repo}"
    p::status "Cloned $repo"
    cd "/home/${USERNAME}/src/${repo}" || continue
    make clean install || p::err "Install failed for ${repo}"
    p::status "$repo was installed"
done

p::status "Userspace setup complete."
p::ahead
