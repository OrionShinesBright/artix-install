#!/bin/bash

p::section "USERSPACE SETUP"
p::info "Preparing home for ${USERNAME}..."
mkdir -p /home/"${USERNAME}"/{Desktop,docs,downs,moosiq,pics,repos,src,vids} || p::err "mkdir on xdg user-dirs failed"
sync
p::status "HOME is ready"

p::info "Getting necessary libs for dwm"
pacman -S libxft libxinerama || p::err "Could not install libxft + libxinerama"
sync
p::status "Installed"

p::info "Cloning suckless software"
mkdir -p /home/"${USERNAME}"/src/suckless || p::err "Could not create suckless dir"
for repo in dwm dmenu st; do
    [ -d /home/"${USERNAME}"/"${repo}" ] || git clone https://git.suckless.org/${repo} /home/"${USERNAME}"/src/suckless/"${repo}" || p::err "Could not clone ${repo}"
	p::status "Cloned $repo"
done

p::info "Cloning yay-bin"
git clone --depth=1 https://aur.archlinux.org/yay-bin.git /home/"${USERNAME}"/src/yay-bin || p::err "Could not clone yay-bin"
p::status "Cloned yay-bin"

p::status "Userspace setup complete."
p::ahead
