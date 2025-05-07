#!/bin/bash

set -e

echo "Welcome to the Arch Linux Installation Script!"

# Set keyboard layout
read -p "Enter your preferred keyboard layout (e.g., us): " kblayout
loadkeys ${kblayout:-us}
echo "Keyboard layout set to $kblayout."

# Verify internet connection
echo "Checking for Ethernet connection..."
if ping -c 1 archlinux.org &>/dev/null; then
    echo "Ethernet connection is active."
else
    echo "No Ethernet connection detected. Attempting to connect to Wi-Fi..."
    echo "Launching iwctl. Please connect to your Wi-Fi manually."
    echo "Example: station wlan0 connect <SSID>"
    iwctl

    echo "Verifying Wi-Fi connection..."
    if ! ping -c 1 archlinux.org &>/dev/null; then
        echo "No internet connection detected. Please check your network and try again."
        exit 1
    fi
fi

# Update system clock
echo "Updating system clock..."
timedatectl set-ntp true

# Partition the disks
lsblk
read -p "Enter the disk to partition (e.g., /dev/sda): " disk
cfdisk "$disk"

# Format the partitions
read -p "Enter the root partition (e.g., /dev/sda1): " rootpart
mkfs.ext4 "$rootpart"

read -p "Enter the EFI partition (if applicable, e.g., /dev/sda2 or leave blank): " efipart
if [ -n "$efipart" ]; then
    mkfs.fat -F32 "$efipart"
fi

# Mount the partitions
mount "$rootpart" /mnt
if [ -n "$efipart" ]; then
    mkdir -p /mnt/boot/efi
    mount "$efipart" /mnt/boot/efi
fi

# Install essential packages
echo "Installing base system..."
if ! pacstrap /mnt base linux linux-firmware; then
    echo "Error: Failed to install the base system."
    exit 1
fi

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Save variables for chroot
echo "$efipart" > /mnt/efipart.txt
echo "$disk" > /mnt/disk.txt

# Chroot into the new system
arch-chroot /mnt /bin/bash <<'EOF'
set -e

# Set timezone
read -p "Enter your timezone (e.g., Region/City): " timezone
ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
hwclock --systohc

# Localization
read -p "Enter your locale (e.g., en_US.UTF-8): " locale
echo "$locale UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=$locale" > /etc/locale.conf

# Set hostname
read -p "Enter your hostname: " hostname
echo "$hostname" > /etc/hostname
{
echo "127.0.0.1   localhost"
echo "::1         localhost"
echo "127.0.1.1   $hostname.localdomain $hostname"
} >> /etc/hosts

# Set root password
echo "Set root password:"
passwd

# Install bootloader
efipart=$(cat /efipart.txt)
disk=$(cat /disk.txt)
if [ -n "$efipart" ]; then
    pacman -S --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
    pacman -S --noconfirm grub
    grub-install --target=i386-pc "$disk"
fi
grub-mkconfig -o /boot/grub/grub.cfg

# Desktop environment selection
echo "Select a desktop environment to install:"
echo "1) GNOME"
echo "2) KDE Plasma"
echo "3) XFCE"
echo "4) None"
read -p "Enter your choice (1-4): " de_choice

case $de_choice in
    1)
        echo "Installing GNOME..."
        pacman -S --noconfirm gnome gnome-extra gdm
        systemctl enable gdm
        ;;
    2)
        echo "Installing KDE Plasma..."
        pacman -S --noconfirm plasma kde-applications sddm
        systemctl enable sddm
        ;;
    3)
        echo "Installing XFCE..."
        pacman -S --noconfirm xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
        systemctl enable lightdm
        ;;
    4)
        echo "No desktop environment will be installed."
        ;;
    *)
        echo "Invalid choice. No desktop environment will be installed."
        ;;
esac
EOF

# Clean up temp files
rm -f /mnt/efipart.txt /mnt/disk.txt

# Unmount and reboot
echo "Unmounting partitions..."
if ! umount -R /mnt; then
    echo "Error: Failed to unmount partitions. Please unmount manually."
    exit 1
fi
echo "Installation complete! Rebooting..."
reboot