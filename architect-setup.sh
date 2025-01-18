#/!bin/bash
source properties.conf

##### ROOT #####
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

##### CONFIGURATION #####
# Grub config
grub-install --target=i386-pc --efi-directory=/boot $DISK
grub-mkconfig -o /boot/grub/grub.cfg

# User config
echo "Adding user $USER..."
useradd -m -G wheel-s /bin/zsh $USER 
echo "$USER:$PASSWORD" | chpasswd
echo "$USER password set"
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Copying scripts
cp -R $HOME/architect /home/$USER/
chown -R $USER: /home/$USER/architect

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