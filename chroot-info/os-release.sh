#!/bin/bash

p::section "CUSTOMIZE OS-RELEASE"
p::info "Edit /etc/os-release to adjust system info (vim will open)"
p::ahead
vim /etc/os-release || p::err "Could not open /etc/os-release in vim"
p::status "Edited /etc/os-release"
p::ahead
