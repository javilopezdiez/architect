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
echo -ne "--------------------------0- INSTALL STARTED...--------------------------\n"
( bash \
	$SCRIPT_DIR/architect-install.sh )|& \
	tee architect-install.log

echo -ne "--------------------------1- SETUP STARTED...----------------------------\n"
( arch-chroot /mnt \
	$HOME/architect/architect-setup.sh )|& \
	tee architect-setup.log

echo -ne "--------------------------2.1- POST-INSTALL PKG-SVC STARTED...-----------\n"
( arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- \
	/home/$USERNAME/architect/architect-pkg-svc.sh )|& \
	tee architect-pkg-svc.log

echo -ne "--------------------------2.1- POST-INSTALL CONFIG COPY STARTED...-------\n"
( arch-chroot /mnt \
	sudo rm -rf /home/lost+found)|& \
	tee $HOME/lost+found.log

( arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- \
	/home/$USERNAME/architect/config/home/loncelot/.local/bin/mybackup.sh \
	-d=/home/$USERNAME/architect/config -r )|& \
	tee architect-backup.log

( arch-chroot /mnt /usr/bin/runuser -u $USERNAME -- \
	sudo grub-mkconfig -o /boot/grub/grub.cfg )|& \
	tee grub-mkconfig.log

echo -ne "--------------------------2- POST-INSTALL ENDED...-----------------------\n"

# LOGS
cp -v *.log /mnt/home/$USERNAME/architect
