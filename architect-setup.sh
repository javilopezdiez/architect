#/!bin/bash
# Command for execution
# bash -c "curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-setup.sh | bash" > /mnt/architect-setup.log

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

echo "SETUP STARTED..."
# Grub configuration
grub-install --target=i386-pc $DISK
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
echo -e "LANG=en_US.UTF-8\nLC_NUMERIC=es_ES.UTF-8\nLC_TIME=es_ES.UTF-8\nLC_MONETARY=es_ES.UTF-8\nLC_PAPER=es_ES.UTF-8\nLC_NAME=es_ES.UTF-8\nLC_ADDRESS=es_ES.UTF-8\nLC_TELEPHONE=es_ES.UTF-8\nLC_MEASUREMENT=es_ES.UTF-8\nLC_IDENTIFICATION=es_ES.UTF-8" > /etc/locale.conf
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

echo "SETUP COMPLETED..."