# Arch Linux Installer

This project provides an interactive installation script for Arch Linux, allowing users to easily set up their system with a variety of software packages. The installation process is designed to be user-friendly, guiding users through the selection of essential components for their Arch Linux environment.

## Features

- **Interactive Installation**: Users can select from a menu of software packages to install, including:
  - Base System
  - Desktop Environments (GNOME, KDE Plasma, XFCE, LXQt)
  - Web Browsers (Firefox, Chromium)
  - Media Players (VLC, MPV)
  - Development Tools (Base-devel, Git)
  - Utilities (htop, neofetch)

- **Post-Installation Configuration**: After the main installation, a post-installation script can be executed to configure the installed software and set up user accounts.

- **Helper Functions**: The project includes helper scripts to streamline package installation and configuration management.

## Installation Instructions

1. Clone the repository:
   ```
   git clone <repository-url>
   cd arch-linux-installer
   ```

2. Make the installation script executable:
   ```
   chmod +x scripts/install.sh
   ```

3. Run the installation script:
   ```
   ./scripts/install.sh
   ```

4. Follow the on-screen instructions to select and install your desired software packages.

## Usage Guidelines

- Ensure you have a working Arch Linux environment before running the installation script.
- Review the configuration files in the `configs` directory to customize your installation as needed.
- After installation, you may want to run the `post-install.sh` script to finalize your setup.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.