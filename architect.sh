#!/bin/bash

# Installing DEPENDENCIES
echo "Installing dependencies."
pacman -Sy --noconfirm --needed git

# Cloning scripts
echo "Cloning the architect script"
git clone https://github.com/javilopezdiez/architect
cd architect
set -a
SCRIPT_DIR="$(pwd)"
set +a
source $SCRIPT_DIR/properties.conf

# SCRIPTS
echo -ne "--------------------------0- INSTALL STARTED...----------------\n"
( bash \
    $SCRIPT_DIR/architect-install.sh )|& \
    tee architect-install.log

echo -ne "--------------------------1- SETUP STARTED...------------------\n"
( arch-chroot /mnt \
    $HOME/architect/architect-setup.sh )|& \
    tee architect-setup.log

echo -ne "--------------------------2.1- POST-INSTALL PKG STARTED...-------\n"

( arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- \
    /home/$USERNAME/architect/architect-pkg-cfg.sh )|& \
    tee architect-pkg.log

echo -ne "--------------------------2- POST-INSTALL COMPLETED...---------\n"

# LOGS
cp -v *.log /mnt/home/$USERNAME
