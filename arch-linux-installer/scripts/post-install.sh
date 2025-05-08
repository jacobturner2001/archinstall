#!/bin/bash

set -e

# Function to create a new user
create_user() {
    read -p "Enter the username for the new user: " username
    useradd -m -G wheel "$username"
    echo "User $username created."
    passwd "$username"
}

# Function to configure sudoers
configure_sudoers() {
    echo "Configuring sudoers..."
    echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
}

# Function to enable services
enable_services() {
    echo "Enabling necessary services..."
    systemctl enable NetworkManager
}

# Function to set up system settings
setup_system_settings() {
    echo "Applying system settings..."
    # Example: Set the timezone
    timedatectl set-timezone America/New_York
}

# Main post-installation tasks
echo "Starting post-installation tasks..."

create_user
configure_sudoers
enable_services
setup_system_settings

echo "Post-installation tasks completed. You can now reboot your system."