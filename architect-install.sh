#/!bin/bash
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
swapoff "${DISK}"* 2>/dev/null \
    || echo "No swap to disable on $DISK."
echo "Wiping filesystem signatures and metadata on $DISK..."
sgdisk -Z ${DISK}
sgdisk -a 2048 -o ${DISK} \
    || { echo "Error creating partition table"; exit 1; }
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
parted -s "$DISK" mkpart primary ext4 "$ROOT_END"MiB $HOME_END \
    || { echo "Error creating home partition"; exit 1; }
# Formatting
echo "Formatting partitions..."
if [[ -d "/sys/firmware/efi" ]]; then
    echo "Formatting UEFI boot partition..."
    mkfs.fat -F32 ${DISK}$((1+N))
else
    echo "Formatting BIOS boot partition..."
    mkfs.ext4 -F ${DISK}$((1+N))
fi
mkswap ${DISK}$((2+N))
swapon ${DISK}$((2+N))
mkfs.ext4 -F ${DISK}$((3+N))
mkfs.ext4 -F ${DISK}$((4+N))
# Mounting partitions
echo "Mounting partitions..."
mount ${DISK}$((3+N)) /mnt
if [[ -d "/sys/firmware/efi" ]]; then
    mkdir -p /mnt/boot/efi
    mount ${DISK}$((1+N)) /mnt/boot/efi
else
    mkdir /mnt/boot
    mount ${DISK}$((1+N)) /mnt/boot
fi
mkdir /mnt/home
mount ${DISK}$((4+N)) /mnt/home
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