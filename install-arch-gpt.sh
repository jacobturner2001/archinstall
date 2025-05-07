#!/bin/bash

set -e

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

# Function to check internet connection
check_internet() {
    if ! ping -c 1 archlinux.org &> /dev/null; then
        echo "No internet connection. Please connect to the internet and try again."
        exit 1
    fi
}

# Function to check if system is booted in UEFI mode
check_uefi() {
    if [ ! -d "/sys/firmware/efi" ]; then
        echo "System is not booted in UEFI mode. This script requires UEFI."
        exit 1
    fi
}

# Function to list available disks
list_disks() {
    echo "Available disks:"
    lsblk -d -o NAME,SIZE,MODEL
}

# Check prerequisites
check_root
check_internet
check_uefi

# Interactive disk selection
list_disks
read -p "Enter the target disk (e.g., /dev/sda): " DISK
if [ ! -b "$DISK" ]; then
    echo "Invalid disk device: $DISK"
    exit 1
fi

# Interactive user input
read -p "Enter hostname: " HOSTNAME
read -p "Enter username: " USERNAME
read -s -p "Enter password: " PASSWORD
echo
read -s -p "Confirm password: " PASSWORD_CONFIRM
echo

if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Passwords do not match"
    exit 1
fi

# Timezone selection
echo "Selecting timezone..."
tzselect

# Partitioning
echo "Partitioning the disk..."
parted $DISK --script mklabel gpt
parted $DISK --script mkpart primary fat32 1MiB 512MiB
parted $DISK --script set 1 esp on
parted $DISK --script mkpart primary linux-swap 512MiB 4.5GiB
parted $DISK --script mkpart primary ext4 4.5GiB 100%

# Formatting
echo "Formatting partitions..."
mkfs.fat -F32 "${DISK}1"
mkswap "${DISK}2"
mkfs.ext4 "${DISK}3"

# Mounting
echo "Mounting partitions..."
mount "${DISK}3" /mnt
mkdir -p /mnt/boot
mount "${DISK}1" /mnt/boot
swapon "${DISK}2"

# Install base system
echo "Installing base system..."
if ! pacstrap /mnt base linux linux-firmware sudo; then
    echo "Error: Failed to install the base system."
    exit 1
fi

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
echo "Entering chroot..."
arch-chroot /mnt /bin/bash <<EOF

# Timezone and localization
ln -sf /usr/share/zoneinfo/\$(cat /etc/timezone) /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname and hosts
echo "$HOSTNAME" > /etc/hostname
cat <<EOL > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOL

# Initramfs
mkinitcpio -P

# Root password
echo "root:$PASSWORD" | chpasswd

# Bootloader
pacman -S --noconfirm grub efibootmgr
if ! grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB; then
    echo "Error: GRUB installation failed."
    exit 1
fi
grub-mkconfig -o /boot/grub/grub.cfg

# User setup
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Install KDE Plasma, Xorg, Wayland, and Hyprland
pacman -S --noconfirm xorg plasma kde-applications wayland hyprland-meta git base-devel sddm networkmanager

# Enable services
systemctl enable sddm.service
systemctl enable NetworkManager.service

EOF

# Unmount and reboot
echo "Installation complete. Unmounting and rebooting..."
umount /mnt/boot
umount -R /mnt
swapoff -a

read -p "Installation complete. Press Enter to reboot..."
reboot