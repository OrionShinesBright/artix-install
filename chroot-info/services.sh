#!/bin/bash

p::section "RUNNIT SERVICES"
mkdir -p /etc/runit/runsvdir/default || p::err "Could not create default runsvdir"
for svc in NetworkManager chronyd; do
    if [ -d "/etc/runit/sv/$svc" ]; then
        ln -sf "/etc/runit/sv/$svc" /etc/runit/runsvdir/default/ || echo -e "${RED}Failed to link $svc ${RESET}"
    else
        echo -e "${RED}Service $svc not found in /etc/runit/sv/${RESET}"
    fi
done
p::status "Linking completed"
p::ahead
