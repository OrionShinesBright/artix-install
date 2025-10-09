#!/bin/bash

p::section "RUNNIT SERVICES"
p::info "Linking chrony and nm"
mkdir -p /etc/runit/runsvdir/default || p::err "Could not create default runsvdir"
for svc in NetworkManager chrony; do
	if [ -d "/etc/runit/sv/$svc" ]; then
		ln -sf "/etc/runit/sv/$svc" /etc/runit/runsvdir/default/ || p::err "Failed to link $svc"
	else
		p::err "Service $svc not found"
	fi
done
p::status "Linking completed"
p::ahead
