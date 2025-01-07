#/!bin/bash
# Command for execution
# bash -c "curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-setup.sh | bash" > /mnt/architect-setup.log

##### VARIABLES #####
USER=loncelot
HOSTNAME=architect
DISK="/dev/vda"
LOCATION="Europe/Madrid"
KEYMAP="es"
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
grub-install --target=i386-pc --efi-directory=/boot $DISK
grub-mkconfig -o /boot/grub/grub.cfg

# User config
echo "Adding user $USER..."
useradd -m -g wheel $USER
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Host config
echo "Naming host $HOSTNAME..."
echo "$HOSTNAME" > /etc/hostname
echo "127.0.0.1 localhost" > /etc/hosts

# Localization config
echo "Configuring localization..."
echo "KEYMAP=${KEYMAP}" > /etc/vconsole.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
# echo -e "LANG=en_US.UTF-8\nLC_NUMERIC=es_ES.UTF-8\nLC_TIME=es_ES.UTF-8\nLC_MONETARY=es_ES.UTF-8\nLC_PAPER=es_ES.UTF-8\nLC_NAME=es_ES.UTF-8\nLC_ADDRESS=es_ES.UTF-8\nLC_TELEPHONE=es_ES.UTF-8\nLC_MEASUREMENT=es_ES.UTF-8\nLC_IDENTIFICATION=es_ES.UTF-8" > /etc/locale.conf
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_US ISO-8859-1/en_US ISO-8859-1/' /etc/locale.gen
sed -i 's/^#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#es_ES ISO-8859-1/es_ES ISO-8859-1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/${LOCATION} /etc/localtime
localectl --no-ask-password set-keymap ${KEYMAP}

#Add parallel downloading
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
# Package manager update
sudo pacman -Syu --noconfirm --needed

# Desktop environment isntall
echo "Installing xfce Desktop environment..."

# sudo bash -c "curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-pkg.sh | bash" > /mnt/architect-pkg.log
curl -L -o /home/$USER/.architect-pkg.sh https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-pkg.sh

echo "SETUP COMPLETED..."

# Password config
# echo "Please, Insert root passwd"
# passwd
# echo "Please, Insert your passwd"
# passwd $USER

# Sys reboot
# echo "Do you want to reboot the system? (y/n)"
# read -r choice
# if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
#     echo "Rebooting the system..."
#     sudo reboot
# else
#     echo "Reboot cancelled."
# fi

echo "Dont forget to set passwd for root and $USER..."
echo "Afterwars, run architect-pkg.sh"