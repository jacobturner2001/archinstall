#!/bin/bash

set -e

# Variables
ISO_NAME="custom-arch-linux.iso"
WORK_DIR="/tmp/archiso"
ARCH_ISO="archlinux.iso"

# Step 1: Download Arch Linux ISO
echo "Downloading Arch Linux ISO..."
curl -o $ARCH_ISO https://archlinux.org/iso/latest/archlinux-x86_64.iso

# Step 2: Extract ISO
echo "Extracting ISO..."
mkdir -p $WORK_DIR
7z x $ARCH_ISO -o$WORK_DIR/iso

# Step 3: Add custom script
echo "Adding custom script..."
cp scripts/install-arch-gpt.sh $WORK_DIR/iso/airootfs/root/

# Step 4: Modify bootloader to run script
echo "Modifying bootloader..."
cat <<EOF >> $WORK_DIR/iso/loader/entries/archiso-x86_64.conf
title   Custom Arch Linux Install
linux   /arch/boot/x86_64/vmlinuz-linux
initrd  /arch/boot/intel-ucode.img
initrd  /arch/boot/amd-ucode.img
initrd  /arch/boot/x86_64/initramfs-linux.img
options archisobasedir=arch archiso_nfs_srv=::/root/install-arch-gpt.sh
EOF

# Step 5: Repack ISO
echo "Repacking ISO..."
mkisofs -o $ISO_NAME -b isolinux/isolinux.bin -c isolinux/boot.cat \
    -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "CUSTOM_ARCH" $WORK_DIR/iso

echo "Custom ISO created: $ISO_NAME"