#!/bin/bash

p::section "CUSTOMIZE OS-RELEASE"
p::info "Edit /etc/os-release to adjust system info ($EDITOR will open)"
sleep 1
vim /etc/os-release || true
p::status "Edited /etc/os-release"
p::ahead
