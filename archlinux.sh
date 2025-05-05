#!/bin/bash

set -e

echo "Welcome to the Arch Linux Interactive Installer!"

# Connect to Wi-Fi using iwctl (interactive)
echo "Launching iwctl. Please connect to your Wi-Fi manually."
echo "Example: station wlan0 connect <SSID>"
iwctl

# Verify internet connection
echo "Verifying internet connection..."
if ping -c 1 archlinux.org &>/dev/null; then
    echo "Internet connection is active."
else
    echo "No internet connection detected. Please check your network and try again."
    exit 1
fi

# Set keyboard layout
read -p "Enter your preferred keyboard layout (default: us): " kblayout
kblayout=${kblayout:-us}
loadkeys "$kblayout"
echo "Keyboard layout set to $kblayout."

# Partition the disk
lsblk
read -p "Enter the disk to partition (e.g., /dev/sda): " disk
echo "Launching cfdisk for disk partitioning..."
cfdisk "$disk"

# Format partitions
read -p "Enter the root partition (e.g., /dev/sda1): " root_partition
mkfs.ext4 "$root_partition"
read -p "Enter the EFI partition (if applicable, e.g., /dev/sda2, or leave blank): " efi_partition
if [ -n "$efi_partition" ]; then
    mkfs.fat -F32 "$efi_partition"
fi

# Mount partitions
mount "$root_partition" /mnt
if [ -n "$efi_partition" ]; then
    mkdir -p /mnt/boot/efi
    mount "$efi_partition" /mnt/boot/efi
fi

# Install base system
echo "Installing base system..."
pacstrap /mnt base linux linux-firmware networkmanager sudo

# Generate fstab
echo "Generating fstab..."
mkdir -p /mnt/etc
genfstab -U /mnt >> /mnt/etc/fstab

# Collect config before chroot
read -p "Enter hostname: " hostname
echo "$hostname" > /mnt/hostname.txt

echo "Select your preferred desktop environment:"
echo "1) KDE Plasma"
echo "2) GNOME"
echo "3) XFCE"
echo "4) None (minimal installation)"
read -p "Enter your choice (1-4): " de_choice
echo "$de_choice" > /mnt/de_choice.txt

# Chroot into the system and finish setup
arch-chroot /mnt /bin/bash <<'EOF'
set -e

# Set timezone
ln -sf /usr/share/zoneinfo/$(curl -s https://ipapi.co/timezone) /etc/localtime
hwclock --systohc

# Set locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Set hostname
hostname=$(cat /hostname.txt)
echo "$hostname" > /etc/hostname
{
echo "127.0.0.1   localhost"
echo "::1         localhost"
echo "127.0.1.1   $hostname.localdomain $hostname"
} >> /etc/hosts

# Set root password
echo "Set root password:"
passwd

# Enable network manager
systemctl enable NetworkManager

# Install bootloader
if mount | grep -q "/boot/efi"; then
    pacman -S --noconfirm grub efibootmgr
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
    pacman -S --noconfirm grub
    grub-install --target=i386-pc /dev/sda
fi
grub-mkconfig -o /boot/grub/grub.cfg

# Install desktop environment
de_choice=$(cat /de_choice.txt)
case "$de_choice" in
    1)
        echo "Installing KDE Plasma..."
        pacman -S --noconfirm xorg plasma kde-applications sddm
        systemctl enable sddm.service
        ;;
    2)
        echo "Installing GNOME..."
        pacman -S --noconfirm xorg gnome gnome-extra gdm
        systemctl enable gdm.service
        ;;
    3)
        echo "Installing XFCE..."
        pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
        systemctl enable lightdm.service
        ;;
    4)
        echo "Skipping desktop environment installation."
        ;;
    *)
        echo "Invalid choice. Skipping desktop environment installation."
        ;;
esac
EOF

# Clean up temp files
rm -f /mnt/hostname.txt /mnt/de_choice.txt

# Unmount and reboot
umount -R /mnt
echo "Installation complete! Rebooting..."
reboot
# End of script