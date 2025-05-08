#!/bin/bash

# Function to install packages
install_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -gt 0 ]; then
        echo "Installing packages: ${packages[*]}"
        pacman -S --noconfirm "${packages[@]}"
    else
        echo "No packages selected."
    fi
}

# Function to check if a package is installed
is_package_installed() {
    local package="$1"
    if pacman -Q "$package" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to create a user with specified username
create_user() {
    local username="$1"
    useradd -m -G wheel "$username"
    echo "User $username created."
}

# Function to set password for a user
set_user_password() {
    local username="$1"
    passwd "$username"
}

# Function to enable a service
enable_service() {
    local service="$1"
    systemctl enable "$service"
    echo "Service $service enabled."
}

# Function to start a service
start_service() {
    local service="$1"
    systemctl start "$service"
    echo "Service $service started."
}