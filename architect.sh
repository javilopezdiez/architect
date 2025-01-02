#/!bin/bash
# Command for execution
# curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect.sh && sudo bash architect.sh |& tee architect.log

##### VARIABLES #####
USER=loncelot
HOSTNAME=architect
DISK="/dev/vda"
LAYOUT="es"
LOCATION="Europe/Madrid"
PART_BOOT="500M"
PART_SWAP="3G"
PART_ROOT="15G"
PART_HOME="" # If empty, remaining space

##### ROOT #####
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "INSTALL STARTED..."
##### DEPENDENCIES #####
echo "Installing numfmt for partitioning..."
pacman -Sy --needed numfmt --noconfirm

##### CONFIGURATION #####
# keyboard config
echo "Setting keyboard layout to $LAYOUT..."
loadkeys $LAYOUT

# Setting clock
echo "Setting clock and timezone to $LOCATION..."
timedatectl set-ntp true
timedatectl set-timezone "$LOCATION"

# Partitioning BOOT - SWAP - ROOT - HOME
# Calculation
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

# Formatting Drive
echo "Unmounting partitions on $DISK..."
umount -A --recursive /mnt
echo "Disabling swap if any on $DISK..."
swapoff "${DISK}"* 2>/dev/null \
    || echo "No swap to disable on $DISK."
echo "Wiping filesystem signatures and metadata on $DISK..."
sgdisk -Z ${DISK}
sgdisk -a 2048 -o ${DISK} \
    || { echo "Error creating partition table"; exit 1; }
# BIOS boot
echo "Creating BIOS boot partition..."
parted -s "$DISK" mkpart primary 1MiB 3MiB \
    || { echo "Error creating BIOS boot partition"; exit 1; }
parted -s "$DISK" set 1 bios_grub on \
    || { echo "Error setting BIOS boot flag"; exit 1; }
# Boot
echo "Creating boot partition of size $PART_BOOT..."
parted -s "$DISK" mkpart primary ext4 3MiB "$BOOT_END"MiB \
    || { echo "Error creating boot partition"; exit 1; }
# Swap
echo "Creating swap partition of size $PART_SWAP..."
parted -s "$DISK" mkpart primary linux-swap "$BOOT_END"MiB "$SWAP_END""MiB" \
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
mkfs.ext4 -F ${DISK}1
mkswap ${DISK}2
swapon ${DISK}2
mkfs.ext4 -F ${DISK}3
mkfs.ext4 -F ${DISK}4
# Mounting partitions
echo "Mounting partitions..."
mount ${DISK}4 /mnt
mkdir /mnt/boot
mount ${DISK}2 /mnt/boot
mkdir /mnt/home
mount ${DISK}5 /mnt/home
lsblk $DISK

##### ROOT #####
# Updating keyrings to latest to prevent packages failing to install
echo "Updating keyrings"
pacman -Sy --needed archlinux-keyring --noconfirm
# Installing base system
echo "Installing base system..."
pacstrap /mnt linux linux-firmware base base-devel grub networkmanager --noconfirm

# Saving mounting config
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Changing the root directory to /mnt
arch-chroot /mnt bash -c "curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-setup.sh | bash" > /mnt/architect-setup.log

echo "INSTALL COMPLETED..."