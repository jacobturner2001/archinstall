#!/bin/bash

# Custom setup script for Arch Linux installation

# Update the system clock
timedatectl set-ntp true

# Install additional packages
pacman -S --noconfirm vim git

# Enable necessary services
systemctl enable NetworkManager

# Create a new user with sudo privileges
useradd -m -G wheel -s /bin/bash customuser
echo "customuser:password" | chpasswd
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set up SSH server
pacman -S --noconfirm openssh
systemctl enable sshd

# Additional custom configurations can be added here
# For example, setting up a firewall or installing other software

echo "Custom setup completed."