#!/bin/bash

set -e

# Function to connect to Wi-Fi using iwctl
connect_wifi() {
    echo "Checking for active internet connection..."
    if ping -c 1 -W 3 archlinux.org &>/dev/null; then
        echo "Internet connection is active."
    else
        echo "No active internet connection detected."
        if ! command -v iwctl &>/dev/null; then
            echo "Error: iwctl is not installed. Please install it and try again."
            exit 1
        fi
        echo "Starting iwctl for Wi-Fi setup..."
        echo "Follow these steps to connect to Wi-Fi:"
        echo "1. Type 'device list' to find your wireless device."
        echo "2. Type 'station <device> scan' to scan for networks."
        echo "3. Type 'station <device> get-networks' to list available networks."
        echo "4. Type 'station <device> connect <SSID>' to connect to your network."
        echo "5. Type 'exit' to quit iwctl."
        iwctl
        echo "Rechecking internet connection..."
        if ping -c 1 -W 3 archlinux.org &>/dev/null; then
            echo "Internet connection established."
        else
            echo "Failed to establish an internet connection. Exiting..."
            exit 1
        fi
    fi
}


# Function to create a new user
create_user() {
    echo "Creating a new user..."
    read -p "Enter the username: " username
    if id "$username" &>/dev/null; then
        echo "User $username already exists."
    else
        useradd -m -G wheel -s /bin/bash "$username"
        echo "Set a password for $username:"
        passwd "$username"
        echo "User $username created and added to the wheel group."
    fi

    echo "Configuring sudo access for the wheel group..."
    sed -i '/%wheel ALL=(ALL:ALL) ALL/s/^# //' /etc/sudoers
    echo "Sudo access configured."
}


# Function to display the main menu
show_menu() {
    echo "Select the software you want to install:"
    echo "1) Base System"
    echo "2) Desktop Environment"
    echo "3) Web Browser"
    echo "4) Media Player"
    echo "5) Development Tools"
    echo "6) Utilities"
    echo "7) Install Additional Software"
    echo "8) Configure System Settings"
    echo "9) Finish Installation"
    echo "10) Exit"
}

# Function to install selected packages
install_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -gt 0 ]; then
        echo "Installing packages: ${packages[*]}"
        pacman -S --noconfirm "${packages[@]}"
    else
        echo "No packages selected."
    fi
}

# Function to configure system settings
configure_system() {
    echo "Configuring system settings..."
    echo "1) Set Locale"
    echo "2) Set Timezone"
    echo "3) Configure Pacman Mirrors"
    echo "4) Enable Services (e.g., Bluetooth, CUPS)"
    read -p "Enter your choice [1-4]: " config_choice
    case $config_choice in
        1)
            echo "Setting locale..."
            echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
            locale-gen
            echo "LANG=en_US.UTF-8" > /etc/locale.conf
            ;;
        2)
            echo "Setting timezone..."
            ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
            hwclock --systohc
            ;;
        3)
            echo "Configuring Pacman mirrors..."
            pacman -S --noconfirm reflector
            reflector --country UnitedStates --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
            
# Function to display the main menu
show_menu() {
    echo "Select the software you want to install:"
    echo "1) Base System"
    echo "2) Desktop Environment"
    echo "3) Web Browser"
    echo "4) Media Player"
    echo "5) Development Tools"
    echo "6) Utilities"
    echo "7) Install Additional Software"
    echo "8) Configure System Settings"
    echo "9) Finish Installation"
    echo "10) Exit"
}

# Function to install selected packages
install_packages() {
    local packages=("$@")
    if [ ${#packages[@]} -gt 0 ]; then
        echo "Installing packages: ${packages[*]}"
        pacman -S --noconfirm "${packages[@]}"
    else
        echo "No packages selected."
    fi
}

# Function to configure system settings
configure_system() {
    echo "Configuring system settings..."
    echo "1) Set Locale"
    echo "2) Set Timezone"
    echo "3) Configure Pacman Mirrors"
    echo "4) Enable Services (e.g., Bluetooth, CUPS)"
    read -p "Enter your choice [1-4]: " config_choice
    case $config_choice in
        1)
            echo "Setting locale..."
            echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
            locale-gen
            echo "LANG=en_US.UTF-8" > /etc/locale.conf
            ;;
        2)
            echo "Setting timezone..."
            ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
            hwclock --systohc
            ;;
        3)
                        echo "Configuring Pacman mirrors..."
                        pacman -S --noconfirm reflector
                        reflector --country UnitedStates --latest 5 --sort rate --save /etc/pacman.d/mirrorlist
                        ;;
                    4)
                        echo "Enabling services..."
                        systemctl enable bluetooth.service
                        systemctl enable cups.service
                        ;;
                    *)
                        echo "Invalid choice. Returning to the main menu."
                        ;;
                esac
            }