#!/bin/bash

# Installing DEPENDENCIES
echo "Installing dependencies."
pacman -Sy --noconfirm --needed git

# Cloning scripts
echo "Cloning the architect script"
git clone https://github.com/javilopezdiez/architect

# SCRIPTS
cd $HOME/architect
echo -ne "--------------------------0- INSTALL STARTED...----------------"
( bash \
    $HOME/architect/architect-install.sh )|& \
    tee architect-install.log

echo -ne "--------------------------1- SETUP STARTED...------------------"
( arch-chroot /mnt \
    $HOME/architect/architect-setup.sh )|& \
    tee architect-setup.log

echo -ne "--------------------------2- POST-ISNTALL PKG STARTED...-------"
( arch-chroot /mnt /usr/bin/runuser -u $USER -- \
    $HOME/architect/architect-pkg.sh )|& \
    tee architect-pkg.log

echo -ne "--------------------------2- POST-ISNTALL COMPLETED...---------"

# LOGS
cp -v *.log /mnt/home/$USER
