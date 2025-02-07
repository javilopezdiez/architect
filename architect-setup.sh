#/!bin/bash
source $HOME/architect/properties.conf

##### CONFIGURATION #####
# Grub config
if [[ -d "/sys/firmware/efi" ]]; then
    echo "Installing GRUB for EFI boot mode..."
    grub-install --target=x86_64-efi --efi-directory=/boot $DISK
else
    echo "Installing GRUB for legacy (BIOS) boot mode..."
    grub-install --target=i386-pc --boot-directory=/boot $DISK
fi
grub-mkconfig -o /boot/grub/grub.cfg

# User config
echo "Creating virtualization group..."
groupadd libvirt
echo "Adding user $USERNAME..."
useradd -m -G wheel,libvirt -s /bin/bash $USERNAME
# Prompt for the password
echo "Enter password for $USERNAME:"
read -s PASSWORD
echo "Confirm password for $USERNAME:"
read -s PASSWORD_CONFIRM
if [ "$PASSWORD" != "$PASSWORD_CONFIRM" ]; then
    echo "Passwords do not match. Please try again..."
    exit 1
fi
echo "$USERNAME:$PASSWORD" | chpasswd
echo "$USERNAME password set"
echo "root:$PASSWORD" | chpasswd
echo "root password set"
# Admin privileges
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers

# Copying scripts 1
echo "Scripts: Copying scripts 1..."
cp -R $HOME/architect /home/$USERNAME/
chown -R $USERNAME: /home/$USERNAME/architect

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