#!/bin/bash
#set -e
##################################################################################################################################
# Author    : Erik Dubois
# Website   : https://www.erikdubois.be
# Website   : https://www.alci.online
# Website   : https://www.ariser.eu
# Website   : https://www.arcolinux.info
# Website   : https://www.arcolinux.com
# Website   : https://www.arcolinuxd.com
# Website   : https://www.arcolinuxb.com
# Website   : https://www.arcolinuxiso.com
# Website   : https://www.arcolinuxforum.com
##################################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################################
#tput setaf 0 = black
#tput setaf 1 = red
#tput setaf 2 = green
#tput setaf 3 = yellow
#tput setaf 4 = dark blue
#tput setaf 5 = purple
#tput setaf 6 = cyan
#tput setaf 7 = gray
#tput setaf 8 = light blue
##################################################################################################################################

installed_dir=$(dirname $(readlink -f $(basename `pwd`)))

##################################################################################################################################

if [ "$DEBUG" = true ]; then
    echo
    echo "------------------------------------------------------------"
    echo "Running $(basename $0)"
    echo "------------------------------------------------------------"
    echo
    read -n 1 -s -r -p "Debug mode is on. Press any key to continue..."
    echo
fi

##################################################################################################################################

# when on Garuda

if grep -q "Garuda" /etc/os-release; then

	echo
	tput setaf 2
	echo "########################################################################"
	echo "############### We are on an GARUDA iso"
	echo "########################################################################"
	echo
	tput sgr0

	# for EXT4 
	if 	lsblk -f | grep ext4 > /dev/null 2>&1 ; then
		echo
		tput setaf 3
		echo "################################################################## "
		echo "Lets remove packages related to btrfs when on EXT4"
		echo "################################################################## "
	    tput sgr0
	    echo
	    sudo pacman -Rns garuda-system-maintenance
	    sudo pacman -Rns snapper-support snapper-tools
	    sudo pacman -Rns btrfsmaintenance garuda-common-systems
	    sudo pacman -Rns btrfs-assistant btrfs-progs grub-btrfs
	fi    

fi

echo
tput setaf 6
echo "##############################################################"
echo "###################  $(basename $0) done"
echo "##############################################################"
tput sgr0
echo