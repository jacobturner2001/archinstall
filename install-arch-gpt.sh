#!/bin/bash

set -e

# Variables
DISK="/dev/sdX" # Replace with your disk (e.g., /dev/sda)
HOSTNAME="archlinux"
USERNAME="jacob"
PASSWORD="jacob"
DISK="/dev/sda"

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
pacstrap /mnt base linux linux-firmware

# Generate fstab
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Chroot
echo "Entering chroot..."
arch-chroot /mnt /bin/bash <<EOF

# Timezone and localization
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
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
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# User setup
useradd -m -G wheel -s /bin/bash $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
#!/bin/bash




echo "Custom ISO created: $ISO_NAME"

# Install KDE Plasma, Xorg, Wayland, and Hyprland
pacman -S --noconfirm xorg plasma kde-applications sddm wayland hyprland
systemctl enable sddm
systemctl enable NetworkManager

EOF

# Unmount and reboot
echo "Installation complete. Unmounting and rebooting..."
umount -R /mnt
swapoff -a
reboot