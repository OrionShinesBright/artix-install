# artix-install
A(n almost) fully automated artix-install script that I made for no freaking reason whatsoever.. jeez
> [!ATTENTION]
> This installer assumes that the user knows what `vim` is.

# Installation Steps
## Obtaining and Getting into Artix
1. Go **download the artix-base-runit ISO** from [artix website](https://artixlinux.org/download.php) (Recommended to look at the weekly builds).
2. **Burn the ISO** to your USB flash drive.<br>
  a. If on *linux*: look into dd, caligula, or balena-etcher<br>
  b. If on *windows*: look into rufus, and run from ventoy, cuz booiiiiii does ventoy hate artix..<br>
3. MAKE **BACKUPS** OF YOUR EXISTING SYSTEM CUZ THIS SCRIPT WILL **ERASE ALLLLLL DATA** ON YOUR PC. DO *NOT* TAKE THIS LIGHTLY.
4. **Boot** off of the USB, by smashing all the function keys of your PC, immediately after it powers on.
5. Once you are in the **artix splash screen** (The screen that looks blue with weird neon lighting), press your down-arrow to go down (wow) to the option that says `From CD/DVD/ISO blah blah`. Press enter.
6. You are now in big scary darkness (terminal)
## Making the Live Environment Usable
7. The system will scare you for a few seconds, and then scare you more by showing something like: [image]<br>
Please write `root` and press enter, then write `artix` and press enter again when it asks for password.
8. Now.. the fun part. **Connecting to the internet** :) Anything I write here will probably go out of date, so instead, I'll point you to [Artix-wiki InternetConnection](https://wiki.artixlinux.org/Main/Installation#Connect_to_the_Internet). Once you are done, please run
```bash
ping -c 3 google.com; echo $?
```
If that shows `0`, then you're good to go, otherwise, please just connect your phone (connected to internet) by a USB cable, to your laptop. Go into phone settings, and look for `USB Tethering`. Turn this on. Now run the ping command again. This should now work. It will save you about 2 hours of fruitless debugging (speaking from experience).
## Getting this script
9. Here is how you can run it within the running live environment. This script should not take too long. It takes about 25 minutes, from start to finish, on my slow as heck internet (~300K/s)
```bash
pacman -Sy --needed --noconfirm git bash
git clone https://github.com/OrionShinesBright/artix-install.git
```
10. Please go through the script by running the following command, and do not proceed to next step until you have changed the variables at the start according to your liking
```bash
cd ~/artix-install
vim install.sh
```
## Starting the Installation
> [!WARNING]
> PLEASE MAKE **BACKUPS**
> This will delete the entire disk.
11. Run the first part of the script as follows:
```bash
cd ~/artix-install
chmod +x install.sh
./install.sh
```
12. The second part will run after the chroot.
