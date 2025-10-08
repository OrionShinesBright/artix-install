#!/bin/sh

[ -f ~/.xprofile ] && . ~/.xprofile
[ -f ~/pics/wallpaper.jpg ] && feh --bg-fill ~/pics/wallpaper.jpg &
picom --experimental-backends &
xdg-user-dirs-update &
exec dwm
