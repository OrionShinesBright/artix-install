#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
setfont -d

sync
pacman -Syy
sync

source "$PALANTIR/artix_env.sh"; 			sync
source "$PALANTIR/helpers.sh";				sync
source "$PALANTIR/pacman_chroot.sh";		sync
source "$PALANTIR/os-release.sh";			sync
source "$PALANTIR/tz_locale.sh";			sync
source "$PALANTIR/hosts_users_passwds.sh";	sync
source "$PALANTIR/grub.sh";					sync
source "$PALANTIR/services.sh";				sync
source "$PALANTIR/pkg_mgmt.sh";				sync
source "$PALANTIR/xorging.sh";				sync
source "$PALANTIR/userspace.sh";			sync
source "$PALANTIR/audio.sh";				sync
source "$PALANTIR/display-login.sh";		sync
source "$PALANTIR/extras.sh";				sync
source "$PALANTIR/services-core.sh";		sync
source "$PALANTIR/finalize.sh";				sync
