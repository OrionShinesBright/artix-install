#!/bin/bash

sudo pacman -Syu						|| exit 0
cd ~/home/"$USER"/src/suckless 			|| exit 1
cd dwm 		&& sudo make clean install 	|| exit 2
cd ../st 	&& sudo make clean install 	|| exit 3
cd ../dmenu	&& sudo make clean install 	|| exit 4
cd ~/home/"$USER"/src/yay-bin			|| exit 5
makepkg -si 							|| exit 6
cd										|| exit 7
rm -f post-install.sh					|| exit 8
