#!/bin/bash

p::section "FSTAB GENERATION"
fstabgen -L /mnt >> /mnt/etc/fstab || p::err "Fstab could not be generated"
p::status "FSTAB generated."
