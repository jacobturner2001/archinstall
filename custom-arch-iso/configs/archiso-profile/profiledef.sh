# filepath: custom-arch-iso/configs/archiso-profile/profiledef.sh
# Define the profile for the Arch ISO build

# Set the name of the profile
PROFILE_NAME="custom-arch-iso"

# Set the version of the profile
VERSION="1.0"

# Set the description of the profile
DESCRIPTION="A custom Arch Linux ISO with additional configurations and packages."

# Set the architecture
ARCH="x86_64"

# Set the boot mode
BOOT_MODE="uefi"

# Set the default user
DEFAULT_USER="user"

# Set the default hostname
DEFAULT_HOSTNAME="archlinux"

# Set the default password for the user
DEFAULT_PASSWORD="password"

# Set the packages to be included in the ISO
PACKAGES_FILE="packages.x86_64"

# Set the custom setup script
CUSTOM_SETUP_SCRIPT="airootfs/root/custom-setup.sh"

# Set the additional files to be included in the ISO
ADDITIONAL_FILES=()  # Add any additional files if needed

# Set the ISO label
ISO_LABEL="CustomArchISO"

# Set the ISO output directory
OUTPUT_DIR="output"