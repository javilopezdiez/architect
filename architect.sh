#/!bin/bash
# Command for execution
# sudo bash <(curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect.sh)

##### VARIABLES #####
USER=loncelot
HOSTNAME=architect
DISK="/dev/sda"
LAYOUT="es"
LOCATION="Europe/Madrid"
PART_BOOT="500M"
PART_SWAP="12G"
PART_ROOT="50G"
PART_HOME="" # If empty, remaining space

##### ROOT #####
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

echo "INSTALL STARTED..."
##### VARIABLES #####
echo "Installing numfmt for partitioning..."
pacman -Sy --noconfirm --needed numfmt

##### CONFIGURATION #####
# keyboard config
echo "Setting keyboard layout to $LAYOUT..."
loadkeys $LAYOUT

# Setting clock
echo "Setting clock and timezone to $LOCATION..."
timedatectl set-ntp true
timedatectl set-timezone "$LOCATION"

echo "Creating GPT partition table on $DISK..."
parted -s "$DISK" mklabel gpt \
    || { echo "Error creating partition table"; exit 1; }
# Boot
echo "Creating boot partition of size $PART_BOOT..."
parted -s "$DISK" mkpart primary ext4 1MiB "$PART_BOOT" \
    || { echo "Error creating boot partition"; exit 1; }
mkfs.ext4 ${DISK}1
# Swap
echo "Creating swap partition of size $PART_SWAP..."
parted -s "$DISK" mkpart primary linux-swap "$PART_BOOT" \
    "$(( $(numfmt --from=iec "$PART_BOOT") + $(numfmt --from=iec "$PART_SWAP") ))MiB" \
    || { echo "Error creating swap partition"; exit 1; }
mkswap ${DISK}2
swapon ${DISK}2
# Root
echo "Creating root partition of size $PART_ROOT..."
ROOT_START="$(( $(numfmt --from=iec "$PART_BOOT") + $(numfmt --from=iec "$PART_SWAP") ))MiB"
ROOT_END="$(( $(numfmt --from=iec "$ROOT_START") + $(numfmt --from=iec "$PART_ROOT") ))MiB"
parted -s "$DISK" mkpart primary ext4 "$ROOT_START" "$ROOT_END" \
    || { echo "Error creating root partition"; exit 1; }
mkfs.ext4 ${DISK}3
# Home
if [[ -n "$PART_HOME" ]]; then
    HOME_END="$(( $(numfmt --from=iec "$ROOT_END") + $(numfmt --from=iec "$PART_HOME") ))MiB"
else
    PART_HOME="Remaining space"
    HOME_END=100%
fi
echo "Allocating $PART_HOME to root partition..."
parted -s "$DISK" mkpart primary ext4 "$ROOT_END" "$HOME_END" \
    || { echo "Error creating home partition"; exit 1; }
mkfs.ext4 ${DISK}4

# Mounting partitions
echo "Mounting partitions..."
mount ${DISK}3 /mnt
mkdir /mnt/boot
mount ${DISK}1 /mnt/boot
mkdir /mnt/home
mount ${DISK}4 /mnt/home

# Installing base system
echo "Installing base system..."
pacstrap /mnt linux linux-firmware base base-devel grub networkmanager

# Saving mounting config
echo "Generating fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

# Changing the root directory to /mnt
arch-chroot /mnt

# Grub configuration
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

# Root config
# echo "Insert root passwd"
# passwd

# User config
echo "Adding user $USER..."
useradd -m -g wheel $USER
echo "Insert your passwd"
# passwd $USER
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Host config
echo "Naming host $HOSTNAME..."
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts

# Localization config
echo "Configuring localization..."
echo "KEYMAP=es" > /etc/vconsole.conf
localectl set-keymap es
echo -e "LANG=en_US.UTF-8\nLC_NUMERIC=es_ES.UTF-8\nLC_TIME=es_ES.UTF-8\nLC_MONETARY=es_ES.UTF-8\nLC_PAPER=es_ES.UTF-8\nLC_NAME=es_ES.UTF-8\nLC_ADDRESS=es_ES.UTF-8\nLC_TELEPHONE=es_ES.UTF-8\nLC_MEASUREMENT=es_ES.UTF-8\nLC_IDENTIFICATION=es_ES.UTF-8" | sudo tee /etc/locale.conf > /dev/null
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_US ISO-8859-1/en_US ISO-8859-1/' /etc/locale.gen
sed -i 's/^#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#es_ES ISO-8859-1/es_ES ISO-8859-1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime

# Package manager update
sudo pacman -Syu --noconfirm

# AUR helper install
echo "Installing yay AUR helper..."
mkdir /tmp/yay && cd /tmp/yay
curl -OJ 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay'  
makepkg -si --noconfirm
rm -rf /tmp/yay

# Desktop environment isntall
echo "Installing xfce Desktop environment..."
sudo pacman -S xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
sudo systemctl enable lightdm

echo "INSTALL COMPLETED..."