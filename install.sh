#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
[ -z "$DISPLAY" ] && setfont -d

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGFILE="$SCRIPT_DIR/log.txt"
exec > >(tee "$LOGFILE") 2>&1

####################
# BASE-ARTIX Setup #
####################
# Initializing
source "$SCRIPT_DIR/scripts/helpers.sh"; 		sync
source "$SCRIPT_DIR/scripts/validate.sh";		sync
source "$SCRIPT_DIR/scripts/input.sh";			sync
source "$SCRIPT_DIR/scripts/pacman_live.sh";	sync
# Disk/Partition Handling
source "$SCRIPT_DIR/scripts/disk_preparation.sh";	sync
# Basestrapping
source "$SCRIPT_DIR/scripts/basestrapping.sh";		sync

