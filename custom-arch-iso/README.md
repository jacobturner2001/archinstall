# Custom Arch Linux ISO Build

This project provides a set of scripts and configurations to automate the process of building a custom Arch Linux ISO tailored to your needs.

## Project Structure

- **scripts/**: Contains shell scripts for building the ISO and installing Arch Linux.
  - **build-iso.sh**: Automates the process of downloading, extracting, and repacking the Arch Linux ISO.
  - **install-arch-gpt.sh**: Contains the installation process for Arch Linux, including disk setup and user configuration.

- **configs/**: Holds configuration files for the Arch ISO profile.
  - **archiso-profile/**: Contains the profile definition and package list for the custom ISO.
    - **airootfs/**: Includes the root filesystem for the ISO.
      - **root/**: Contains custom setup scripts to be executed during installation.
        - **custom-setup.sh**: A script for additional configuration or installation commands.
    - **packages.x86_64**: Lists packages to be included in the custom ISO for x86_64 architecture.
    - **profiledef.sh**: Defines the profile for the Arch ISO build.

## Usage

1. **Clone the repository**:
   ```
   git clone <repository-url>
   cd custom-arch-iso
   ```

2. **Make the scripts executable**:
   ```
   chmod +x scripts/*.sh
   ```

3. **Build the ISO**:
   ```
   ./scripts/build-iso.sh
   ```

4. **Follow the prompts** to customize your installation as needed.

## Requirements

- An active internet connection to download the Arch Linux ISO and packages.
- Necessary tools installed (e.g., `curl`, `parted`, `mkisofs`, etc.).

## Notes

- Ensure to modify the scripts as needed to fit your specific requirements.
- Review the `configs/archiso-profile/packages.x86_64` file to customize the packages included in your ISO.