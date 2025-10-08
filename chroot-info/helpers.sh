#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

BLUE='\033[1;34m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

p::info() {
	echo -e "${YELLOW}>>> $*${RESET}"
}

p::status() {
	echo -e "${GREEN}+ $*${RESET}"
}

p::err() {
	echo -e "${RED}!!! $* !!!${RESET}"
	exit 1
}

p::ahead() {
	read -p "Press Enter to Continue..."
	clear
}

p::section() {
	local title="$1"
	echo
	echo -e "${BLUE}#-------------------------------------------#"
	echo -e "#  ${title^^}"
	echo -e "#-------------------------------------------#${RESET}"
	echo
}

p::confirm() {
	local prompt="$1"
	read -rp "$prompt (y/n): " ans
	[[ "$ans" == "y" ]] || p::err "Aborted."
}
