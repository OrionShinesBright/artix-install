#!/bin/sh

set -eu

# --------------------------
# Config - EDIT IF NEEDED
# --------------------------
DISK="/dev/nvme0n1"
BOOT_SIZE="+512M"
SWAP_SIZE="+3G"
HOSTNAME="Palantir"
USERNAME="orion"
TIMEZONE="Asia/Karachi"
LOCALE="en_US.UTF-8"
WALLPAPER_SRC="/usr/share/backgrounds/artix/simple.png"
export DISK="/dev/nvme0n1"
export BOOT_SIZE="+512M"
export SWAP_SIZE="+3G"
export HOSTNAME="Palantir"
export USERNAME="orion"
export TIMEZONE="Asia/Karachi"
export LOCALE="en_US.UTF-8"
export WALLPAPER_SRC="/usr/share/backgrounds/artix/simple.png"
# --------------------------

info() {
	printf '>>> %s\n' "$*"
}

if [ "$(id -u)" -ne 0 ]; then
  echo "Run this as root from the Artix live ISO root shell."
  exit 1
fi

info "TARGET DISK: $DISK"
info "Make sure this is correct. Script will wipe it."

# --------------------------
# Stage 1: Partitioning
# --------------------------
info "Wiping partitions on $DISK and creating GPT layout..."
wipefs -af "$DISK"
pacman -Sy --noconfirm --needed gptfdisk parted
sgdisk --zap-all "$DISK"
sync
# Create partitions: 1=EFI, 2=swap, 3=root
sgdisk -n1:0:"$BOOT_SIZE" -t1:ef00 -c1:"EFI System" \
       -n2:0:"$SWAP_SIZE" -t2:8200 -c2:"Linux swap" \
       -n3:0:0 -t3:8300 -c3:"Linux filesystem" \
       "$DISK"
sync
partprobe "$DISK"
sleep 1

# Handles nvme device naming vs sda
case "$DISK" in
  *nvme*) BOOT="${DISK}p1"; SWAP="${DISK}p2"; ROOT="${DISK}p3" ;;
  *)      BOOT="${DISK}1";  SWAP="${DISK}2";  ROOT="${DISK}3"  ;;
esac

info "Formatting partitions..."
mkfs.fat -F32 -n BOOT "$BOOT"
mkswap -L SWAP "$SWAP"
mkfs.ext4 -L ROOT "$ROOT"
sync
info "Mounting partitions..."
swapon /dev/disk/by-label/SWAP || true
mount /dev/disk/by-label/ROOT /mnt
mkdir -p /mnt/boot/efi
mount /dev/disk/by-label/BOOT /mnt/boot/efi
sync

# --------------------------
# Stage 2: Network & time (live)
# --------------------------
info "Ensuring networking..."
rfkill unblock all || true
ip link set wlan0 up 2>/dev/null || true

if ! ping -c 3 -W 2 artixlinux.org >/dev/null 2>&1; then
  info "No network detected. Connect (ethernet, nmcli, or phone tether) and rerun."
  exit 1
fi

info "Temporary time sync using chrony (live environment)..."
pacman -Sy --needed --noconfirm chrony chrony-runit || true
ln -sf /etc/runit/sv/chronyd /run/runit/service/chronyd 2>/dev/null || true
sv up chronyd 2>/dev/null || true
chronyc -a makestep 2>/dev/null || true

# --------------------------
# Stage 3: Pre-basestrap pacman.conf edit (live)
# --------------------------
info "Editing /etc/pacman.conf before basestrap. Opening vim"
sleep 1
vim /etc/pacman.conf || true
info "Press ENTER to continue..."
read -r _

# --------------------------
# Stage 4: Base install (basestrap)
# --------------------------
info "Running basestrap to install Artix base system to /mnt..."
baseStrapping () {
	basestrap -iK --noconfirm /mnt \
		base base-devel \
		runit elogind-runit \
		linux linux-firmware-intel linux-headers \
		sof-firmware \
		grub efibootmgr \
		networkmanager networkmanager-runit \
		intel-ucode \
		vim git \
		zsh zsh-completions \
		chrony chrony-runit || baseStrapping
}
baseStrapping

info "Generating fstab (UUIDs)..."
fstabgen -L /mnt >> /mnt/etc/fstab

# --------------------------
# Stage 5: chroot configuration
# --------------------------
info "Entering chroot for detailed system configuration..."
artix-chroot /mnt /bin/sh <<'CHROOT'
set -eu

# --- Variables from outer env ---
TIMEZONE="${TIMEZONE}"
LOCALE="${LOCALE}"
HOSTNAME="${HOSTNAME}"
USERNAME="${USERNAME}"
WALLPAPER_SRC="${WALLPAPER_SRC}"
info() { printf '>>> %s\n' "$*"; }

# --- Allow the user to edit pacman.conf in chroot ---
info "Edit /etc/pacman.conf inside chroot now if you want to adjust pacman (vim will open)."
sleep 1
vim /etc/pacman.conf || true
info "Press ENTER to continue..."
read -r _

# --- Timezone and locale ---
info "Setting timezone to ${TIMEZONE}..."
ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
hwclock --systohc

info "Enabling locale ${LOCALE}..."
sed -i "s/^#${LOCALE} UTF-8/${LOCALE} UTF-8/" /etc/locale.gen || true
locale-gen || true
cat > /etc/locale.conf <<LC
LANG=${LOCALE}
LC_COLLATE=C
LC

# --- Hostname & hosts ---
info "Configuring hostname..."
echo "${HOSTNAME}" > /etc/hostname
cat > /etc/hosts <<H
127.0.0.1   localhost
::1         localhost
127.0.1.1   ${HOSTNAME}.localdomain ${HOSTNAME}
H

# --- Users & passwords (interactive) ---
info "Creating user '${USERNAME}' and prompting for passwords..."
useradd -m -G wheel,audio,video,storage -s /bin/zsh "${USERNAME}" || true

info "Set root password now:"
passwd

info "Set password for user ${USERNAME}:"
passwd "${USERNAME}"

info "Running visudo for sudoers edits if needed (vim will open)."
EDITOR=vim visudo || true

# --- Bootloader (GRUB) ---
info "Installing GRUB..."
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=grub || true
grub-mkconfig -o /boot/grub/grub.cfg || true

# --- Enable runit services by symlink (NetworkManager, chronyd) ---
info "Linking runit services..."
ln -sf /etc/runit/sv/NetworkManager /etc/runit/runsvdir/default/
ln -sf /etc/runit/sv/chronyd /etc/runit/runsvdir/default/

# --- Add Arch mirrorlist and repo entries, then update ---
info "Adding Arch mirrorlist and repository entries..."
pacman -Sy --noconfirm pacman-contrib curl || true
curl -L 'https://archlinux.org/mirrorlist/all/' -o /etc/pacman.d/mirrorlist-arch || true
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist-arch || true

# --- Build yay-bin as user ---
info "Building yay-bin (AUR helper) as ${USERNAME}..."
su -l "${USERNAME}" -c "git clone https://aur.archlinux.org/yay-bin.git /home/${USERNAME}/yay-bin || true"
su -l "${USERNAME}" -c "cd /home/${USERNAME}/yay-bin && makepkg -si --noconfirm || true"
rm -rf /home/"${USERNAME}"/yay-bin || true
sync

# --- Rank some mirrors ---
yay -S rankmirrors
rankmirrors -n 6 /etc/pacman.d/mirrorlist-arch > /etc/pacman.d/mirrorlist-arch.ranked || true
mv /etc/pacman.d/mirrorlist-arch.ranked /etc/pacman.d/mirrorlist-arch || true

cat >> /etc/pacman.conf <<PAC

[omniverse]
  Server = https://artix.sakamoto.pl/omniverse/$arch
  Server = https://eu-mirror.artixlinux.org/omniverse/$arch
  Server = https://omniverse.artixlinux.org/$arch

# --- Arch Linux repo ---
[extra]
Include = /etc/pacman.d/mirrorlist-arch
PAC

info "Syncing package DB..."
pacman -Syyu --noconfirm || true
pacman-key --init
pacman-key --populate

# --- Configuring makepkg ---
mkdir -p /home/${USERNAME}/.config/pacman
echo 'MAKEFLAGS="--jobs=8"' >> /home/${USERNAME}/.config/pacman/makepkg.conf
echo 'OPTIONS=(!debug !lto)' >> /home/${USERNAME}/.config/pacman/makepkg.conf

# --- Install Xorg, Intel-friendly stack, utilities ---
info "Installing Xorg, mesa, input drivers, compositor, fonts, and tools..."
xorging() {
	pacman -S --noconfirm --needed \
		xorg xorg-server xorg-apps xorg-xinit xorg-xrandr xorg-xsetroot xorg-server-xephyr \
    	xorg-drivers mesa vulkan-intel xf86-video-intel xf86-input-libinput\
    	xf86-input-libinput \
    	feh nsxiv picom \
    	make xdg-user-dirs cups \
    	ttf-liberation ttf-font-awesome ttf-jetbrains-mono-nerd ttf-hack-nerd ttf-noto-fonts-emoji || xorging
}
xorging

# --- User Dirs ---
mkdir -p /home/${USERNAME}/.config
cat >> /home/${USERNAME}/.config/user-dirs.dirs <<userDirs
XDG_DESKTOP_DIR="/home/${USERNAME}/Desktop"
XDG_DOCUMENTS_DIR="/home/${USERNAME}/docs"
XDG_DOWNLOAD_DIR="/home/${USERNAME}/downs"
XDG_MUSIC_DIR="/home/${USERNAME}/moosiq"
XDG_PICTURES_DIR="/home/${USERNAME}/pics"
XDG_PUBLICSHARE_DIR="/home/${USERNAME}/repos"
XDG_TEMPLATES_DIR="/home/${USERNAME}/src"
XDG_VIDEOS_DIR="/home/${USERNAME}/vids"
userDirs

# --- Suckless builds (dwm, dmenu, st) into /usr/local/src ---
info "Cloning and building dwm, dmenu, st..."
mkdir -p /home/${USERNAME}/src
cd /home/${USERNAME}/src
su -l "${USERNAME}" -c "git clone https://git.suckless.org/dwm /home/${USERNAME}/src/dwm || true"
su -l "${USERNAME}" -c "git clone https://git.suckless.org/dmenu /home/${USERNAME}/src/dmenu || true"
su -l "${USERNAME}" -c "git clone https://git.suckless.org/st /home/${USERNAME}/src/st || true"
mkdir -p usr/local/src

# Build as root to install system-wide (but keep sources owned by user)
for repo in dwm dmenu st; do
  if [ -d "/home/${USERNAME}/src/${repo}" ]; then
    cd "/home/${USERNAME}/src/${repo}"
    make clean || true
    make PREFIX=/usr clean || true
    make PREFIX=/usr || true
    make PREFIX=/usr install || true
  fi
done

# chown sources for user ability to rebuild/patch later
chown -R "${USERNAME}:${USERNAME}" /home/"${USERNAME}"/src || true

# --- .xinitrc and .xprofile for the user ---
info "Creating .xinitrc and .xprofile for ${USERNAME}..."
su -l "${USERNAME}" -c "mkdir -p /home/${USERNAME}/.config/picom /home/${USERNAME}/pics || true"

cat > /home/"${USERNAME}"/.xinitrc <<XINIT
#!/bin/sh
# Start user session for DWM
# Start pipewire user services via .xprofile (if present)
[ -f /home/${USERNAME}/.xprofile ] && . /home/${USERNAME}/.xprofile

# Set wallpaper if available
[ -f ~/pics/wallpaper.jpg ] && feh --bg-fill ~/pics/wallpaper.jpg &

# Start compositor
picom --experimental-backends &

# User dirs
xdg-user-dirs-update &

# Start status / bars here if you add them
# exec dwm
exec dwm
XINIT
chown "${USERNAME}:${USERNAME}" /home/"${USERNAME}"/.xinitrc
chmod 755 /home/"${USERNAME}"/.xinitrc

cat > /home/"${USERNAME}"/.xprofile <<XPROFILE
# Environment and user-level services started at X session start

# Start PipeWire user services if not already running
pipewire &> /dev/null &
wireplumber &> /dev/null &

# Start wireplumber (if installed)
# Start pulseaudio compatibility (pipewire-pulse makes pulseaudio clients work)
# Start redshift
redshift -l 24.86:67.01 &> /dev/null &

# Start any user-level background service you want
XPROFILE
chown "${USERNAME}:${USERNAME}" /home/"${USERNAME}"/.xprofile
chmod 644 /home/"${USERNAME}"/.xprofile

# --- greetd + tuigreet (login manager) ---
info "Installing and enabling greetd + tuigreet..."
pacman -S --noconfirm greetd greetd-runit greetd-tuigreet || true
mkdir -p /etc/greetd
cat > /etc/greetd/config.toml <<GCONF
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd startx"
user = "${USERNAME}"
GCONF
ln -sf /etc/runit/sv/greetd /etc/runit/runsvdir/default/ || true

# --- PipeWire + WirePlumber + Pulse compatibility + JACK ---
info "Installing PipeWire stack and WirePlumber..."
pacman -S --noconfirm pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber || true

# --- Make sure audio group and limits are set ---
info "Setting audio group and realtime limits..."
groupadd -f audio || true
usermod -aG audio "${USERNAME}" || true
cat >> /etc/security/limits.conf <<LIM
@audio   -  rtprio     95
@audio   -  memlock    unlimited
LIM

# --- Bluetooth (runit) ---
info "Installing Bluetooth stack and enabling its runit service..."
pacman -S --noconfirm bluez bluez-utils bluez-runit || true
ln -sf /etc/runit/sv/bluetoothd /etc/runit/runsvdir/default/ || true

# --- Cron (cronie) ---
info "Installing cronie (runit) and enabling service..."
pacman -S --noconfirm cronie cronie-runit || true
ln -sf /etc/runit/sv/cronie /etc/runit/runsvdir/default/ || true

# --- DBus (required by many user services) ---
info "Installing dbus (runit) and enabling service..."
pacman -S --noconfirm dbus dbus-runit || true
ln -sf /etc/runit/sv/dbus /etc/runit/runsvdir/default/ || true

# --- Picom config for user (simple) ---
info "Writing basic picom config for ${USERNAME}..."
cat > /home/"${USERNAME}"/.config/picom/picom.conf <<PC
backend = "glx";
vsync = true;
use-damage = true;
focus-exclude = ["x = 0 && y = 0 && override_redirect = true"];
blur: {
    method = "dual_kawase";
    strength = 4;
};
blur-background = true;
PC
chown -R "${USERNAME}:${USERNAME}" /home/"${USERNAME}"/.config/picom

# --- Redshift config (geoclue coords) ---
pacman -S --noconfirm redshift geoclue || true
cat > /etc/geoclue/geoclue.conf <<GC
[redshift]
allowed=true
system=false
users=
GC

# --- Install some useful packages & fonts (system) ---
info "Installing some recommended system packages and fonts..."
pacman -S --noconfirm pavucontrol easyeffects helvum || true

# --- Wallpaper copy if available ---
su -l "${USERNAME}" -c "mkdir -p /home/${USERNAME}/pics" || true
if [ -f "${WALLPAPER_SRC}" ]; then
  cp "${WALLPAPER_SRC}" /home/"${USERNAME}"/pics/wallpaper.jpg || true
  chown "${USERNAME}:${USERNAME}" /home/"${USERNAME}"/pics/wallpaper.jpg || true
fi

# --- Start runit services now (if runit is active in chroot) ---
info "Starting some services now (if available)..."
sv up NetworkManager 2>/dev/null || true
sv up chronyd 2>/dev/null || true
sv up dbus 2>/dev/null || true
sv up greetd 2>/dev/null || true
sv up bluetoothd 2>/dev/null || true
sv up cronie 2>/dev/null || true

info "Chroot configuration complete. Exiting chroot..."
CHROOT

# --------------------------
# Stage 6: Final sync, cleanup, reboot
# --------------------------
info "Syncing disks, unmounting /mnt and turning off swap..."
sync
umount -R /mnt || true
swapoff -a || true

info "Installation finished. Rebooting in 5 seconds..."
sleep 5
reboot
