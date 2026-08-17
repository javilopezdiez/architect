#!/bin/bash
source $SCRIPT_DIR/properties.conf

# Installing DEPENDENCIES
echo "Installing dependencies."
pacman -Sy --noconfirm --needed glibc numfmt

##### CONFIGURATION #####
# keyboard config
echo "Setting keyboard layout to $KEYMAP..."
loadkeys $KEYMAP

# Setting clock
echo "Setting clock and timezone to $LOCATION..."
timedatectl set-ntp true # Fecha sincronizada con internet
timedatectl set-timezone "$LOCATION"

##### PARTITIONING #####
clear
# echo "Available disks:"
# lsblk
# while true; do
#     read -rp "Enter disk to use (e.g. /dev/sda): " DISK
#     if [[ -b "$DISK" ]]; then
#         break
#     fi
#     echo "Invalid disk: $DISK"
#     echo "Please enter an existing disk device."
# done
# echo "DISK=$DISK" > $SCRIPT_DIR/properties.conf
while true; do
    echo "Enter SWAP size (e.g. 4G, 8G, 16G):"
    read -rp "SWAP size: " PART_SWAP
    if [[ "$PART_SWAP" =~ ^[0-9]+([MG])$ ]]; then
        break
    fi
    echo "Invalid size. Please use a format like 4G, 8G, or 512M."
done
while true; do
    echo "Enter ROOT size (e.g. 20G, 50G):"
    read -rp "ROOT size: " PART_ROOT
    if [[ "$PART_ROOT" =~ ^[0-9]+([MG])$ ]]; then
        break
    fi
    echo "Invalid ROOT size. Please use a format like 20G or 500M."
done
# BOOT - SWAP - ROOT - HOME
# M or G to-> bytes to-> megabytes
BOOT_SIZE=$(numfmt --from=iec "$PART_BOOT" | awk '{print $1/1024/1024}')
SWAP_SIZE=$(numfmt --from=iec "$PART_SWAP" | awk '{print $1/1024/1024}')
ROOT_SIZE=$(numfmt --from=iec "$PART_ROOT" | awk '{print $1/1024/1024}')
# rounded to the nearest integer/whole number
BOOT_END=$(printf "%.0f" $((1 + BOOT_SIZE)))
SWAP_END=$(printf "%.0f" $((BOOT_END + SWAP_SIZE)))
ROOT_END=$(printf "%.0f" $((SWAP_END + ROOT_SIZE)))
if [[ -n "$PART_HOME" ]]; then
    HOME_SIZE=$(numfmt --from=iec "$PART_HOME" | awk '{print $1/1024/1024}')
    HOME_END=$(printf "%.0f" $((ROOT_END + HOME_SIZE)))"MiB"
else
    PART_HOME="Remaining space"
    HOME_END=100%
fi
# PRE Formatting Drive
echo "Unmounting partitions on $DISK..."
umount -A --recursive /mnt
echo "Disabling swap if any on $DISK..."
swapoff -a
echo "Wiping filesystem signatures and metadata on $DISK..."
sgdisk --zap-all "$DISK" || {
    echo "Error wiping disk"
    exit 1
}
sgdisk -a 2048 -o "$DISK" || {
    echo "Error creating partition table"
    exit 1
}

# Boot
if [[ -d "/sys/firmware/efi" ]]; then
    echo "Creating UEFI boot partition..."
    N=0
    parted -s "$DISK" mkpart ESP fat32 1MiB "$BOOT_END"MiB \
        || { echo "Error creating EFI partition"; exit 1; }
    parted -s "$DISK" set 1 esp on \
        || { echo "Error setting ESP flag"; exit 1; }
else
    echo "Creating BIOS boot partition..."
    N=1
    parted -s "$DISK" mkpart primary 1MiB 3MiB \
        || { echo "Error creating BIOS boot partition"; exit 1; }
    parted -s "$DISK" set 1 bios_grub on \
        || { echo "Error setting BIOS boot flag"; exit 1; }
    echo "Creating BOOT partition of size $PART_BOOT..."
    parted -s "$DISK" mkpart primary ext4 3MiB "$BOOT_END"MiB \
        || { echo "Error creating boot partition"; exit 1; }
fi
# Swap
echo "Creating swap partition of size $PART_SWAP..."
parted -s "$DISK" mkpart primary linux-swap "$BOOT_END"MiB "$SWAP_END"MiB \
    || { echo "Error creating swap partition"; exit 1; }
# Root
echo "Creating root partition of size $PART_ROOT..."
parted -s "$DISK" mkpart primary ext4 "$SWAP_END"MiB "$ROOT_END"MiB \
    || { echo "Error creating root partition"; exit 1; }
# Home
echo "Allocating $PART_HOME to root partition..."
parted -s "$DISK" mkpart primary ext4 "$ROOT_END"MiB "$HOME_END" \
    || { echo "Error creating home partition"; exit 1; }

echo "Refreshing kernel partition table..."
partprobe "$DISK" || true
udevadm settle

echo "Determining partition naming scheme"
if [[ "$DISK" =~ (nvme|mmcblk|loop) ]]; then
    PART_PREFIX="${DISK}p"
else
    PART_PREFIX="${DISK}"
fi
echo "Determining boot mode and partition offset"
if [[ -d "/sys/firmware/efi" ]]; then
    N=0
    echo "Boot mode: UEFI"
else
    N=1
    echo "Boot mode: BIOS"
fi

BOOT_PART="${PART_PREFIX}$((1 + N))"
SWAP_PART="${PART_PREFIX}$((2 + N))"
ROOT_PART="${PART_PREFIX}$((3 + N))"
HOME_PART="${PART_PREFIX}$((4 + N))"

echo
echo "Partition layout:"
echo "  BOOT: $BOOT_PART"
echo "  SWAP: $SWAP_PART"
echo "  ROOT: $ROOT_PART"
echo "  HOME: $HOME_PART"
echo


# Formatting
echo "Formatting partitions..."
mkswap "$SWAP_PART" || exit 1
swapon "$SWAP_PART" || exit 1
if [[ -d "/sys/firmware/efi" ]]; then
    mkfs.fat -F32 "$BOOT_PART" || exit 1
else
    mkfs.ext4 -F "$BOOT_PART" || exit 1
fi
mkfs.ext4 -F "$ROOT_PART" || exit 1
mkfs.ext4 -F "$HOME_PART" || exit 1

# Mounting partitions
echo "Mounting partitions..."
mkdir -p /mnt
mount "$ROOT_PART" /mnt || exit 1
if [[ -d "/sys/firmware/efi" ]]; then
    mkdir -p /mnt/boot/efi
    mount "$BOOT_PART" /mnt/boot/efi || exit 1
else
    mkdir /mnt/boot
    mount "$BOOT_PART" /mnt/boot || exit 1
fi
mkdir /mnt/home
mount "$HOME_PART" /mnt/home || exit 1
lsblk $DISK

##### INSTALL #####
echo "Updating keyrings..."
pacman -Sy --needed archlinux-keyring --noconfirm
# Installing base system
echo "Installing base system..."
pacstrap /mnt linux \
    linux-firmware \
    base base-devel \
    grub \
    networkmanager \
    nano --noconfirm

# Pacman config 1
echo "Package Manager: keyserver and mirrorlist..."
echo "keyserver hkp://keyserver.ubuntu.com" >> /mnt/etc/pacman.d/gnupg/gpg.conf
cp /etc/pacman.d/mirrorlist /mnt/etc/pacman.d/mirrorlist

# Copying scripts 0
echo "Scripts: Copying scripts 0..."
cp -R $SCRIPT_DIR /mnt/root/architect

# Saving mounting config
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab