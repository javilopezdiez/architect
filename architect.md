
<!-- 
# TOIN
# TODO 
-->

##### Architect Install ####
# IMAGE DOWNLOAD
```bash
wget https://es.mirrors.cicku.me/archlinux/iso/2024.12.01/archlinux-2024.12.01-x86_64.iso --show-progress
```

# VM
```bash
    # VM manager + QEMU
        yay -S virt-manager qemu
        sudo systemctl status libvirtd.service
        sudo systemctl start libvirtd.service
    # Startig by default VM interaction form terminal
        # sudo virsh net-start default
        # sudo virsh net-autostart default
    # Listing
        sudo virsh net-list --all
    # add user so that we don't get prompt for pass
        # sudo usermod -aG libvirt $USER && \
        # sudo usermod -aG libvirt-qemu $USER && \
        # sudo usermod -aG kvm $USER && \
        # sudo usermod -aG input $USER && \
        # sudo usermod -aG disk $USER
    # Shared filesystem
        # Host 
            # View > Details > Memory > Enable shared memory
            # Add hardware
                Filesystem shared
        # Guest
            sudo mount -t virtiofs share /home/foo/share
```

# INSTALLATION
```bash
    # localectl list-keymaps
    loadkeys es
    # setfont ter-v20b
    # If timedatectl NTP returns false
        # timedatectl set-ntp true
    timedatectl set-timezone "Europe/Madrid"
    # if ls /sys/firmware/efi
        # Formatting diferent TOIN
        # mkfs.fat -F32 /dev/sdb1
    # Partitioning the drive 
        fdisk /dev/sda
            # n p +200M /boot
            # n p +12G=150*RAM swap
            # n p +25G /
            # n p /home
    # Formatting partitions
        mkfs.ext4 /dev/sda1
        mkfs.ext4 /dev/sda3
        mkfs.ext4 /dev/sda4
        mkswap /dev/sda2
        swapon /dev/sda2
    # Mounting partitions
        mount /dev/sda3 /mnt
        mkdir /mnt/boot 
        mount /dev/sda1 /mnt/boot
        mkdir /mnt/home
        mount /dev/sda4 /mnt/home
    # Installing base system
        pacstrap /mnt linux linux-firmware base base-devel grub networkmanager screenfetch --noconfirm
    # Save mounting config
        genfstab -U /mnt >> /mnt/etc/fstab
    # Changes the root directory to /mnt
        arch-chroot /mnt
    # Startup configuration
        # Bootmanager
            # TOIN
                # i386-pc: For BIOS/legacy systems.
                # x86_64-efi: For UEFI systems on x86_64 architecture.
                # arm-efi: For UEFI systems on ARM architecture.
            grub-install --target=i386-pc /dev/sda
            grub-mkconfig -o /boot/grub/grub.cfg
        # Networkmanager
            systemctl enable NetworkManager
    # Admin config
        passwd
    # User config
        # m generate home g name of the group the user's going to be added to
        useradd -m -g wheel loncelot
        passwd loncelot
        sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' /etc/sudoers
    # Host config
        echo "archpad" > /etc/hostname
        echo "127.0.0.1 localhost" > /etc/host
    # Localization config
        echo "KEYMAP=es" > /etc/vconsole.conf
        sudo localectl set-keymap es
        # Simple conf
        # echo "LANG=en_US.UTF-8" > /etc/locale.conf
        # Complete conf, spanish but language
        echo -e "LANG=en_US.UTF-8\nLC_NUMERIC=es_ES.UTF-8\nLC_TIME=es_ES.UTF-8\nLC_MONETARY=es_ES.UTF-8\nLC_PAPER=es_ES.UTF-8\nLC_NAME=es_ES.UTF-8\nLC_ADDRESS=es_ES.UTF-8\nLC_TELEPHONE=es_ES.UTF-8\nLC_MEASUREMENT=es_ES.UTF-8\nLC_IDENTIFICATION=es_ES.UTF-8" | sudo tee /etc/locale.conf > /dev/null
        # locale-gen
        # Either appending
            # echo "en_US.UTF8 UTF8" >> /etc/locale.gen
            # echo "en_US ISO-8859-1" >> /etc/locale.gen
            # echo "es_ES.UTF8 UTF8" >> /etc/locale.gen
            # echo "es_ES ISO-8859-1" >> /etc/locale.gen
        # Or commenting
            sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
            sed -i 's/^#en_US ISO-8859-1/en_US ISO-8859-1/' /etc/locale.gen
            sed -i 's/^#es_ES.UTF-8 UTF-8/es_ES.UTF-8 UTF-8/' /etc/locale.gen
            sed -i 's/^#es_ES ISO-8859-1/es_ES ISO-8859-1/' /etc/locale.gen
        locale-gen
    # Timezone symbolic link
        ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
    # AUR helper install
        mkdir /tmp/yay && cd /tmp/yay
        # j if the server provides dynamic name it'll be that
        # o if the server doesnt provide name same filename as the server one
        curl -OJ 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay'  
        # s dependencies before building
        # i install after build
        makepkg -si --noconfirm
        rm -rf /tmp/yay
    # Desktop environment isntall
        sudo pamcan -Syu xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter --noconfirm
        sudo systemctl enable lightdm
```

```bash
    # Restarting xfwm4
    xfwm4 --replace &

    # curl -L -o architect.sh https://raw.githubusercontent.com/javilopezdiez/architect/main/architect.sh && sudo bash architect.sh |& tee architect.log

    # Changing the root directory to /mnt
    # arch-chroot /mnt bash -c "curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-setup.sh | bash" > /mnt/architect-setup.log
    curl -L -o /mnt/architect-setup.sh https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-setup.sh
    ( arch-chroot /mnt bash -c /mnt/architect-setup.sh )|& tee architect-setup.log

    sudo bash -c "curl -L https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-pkg.sh | bash" > /mnt/architect-pkg.log
    # echo "Downloading post-installer to /home/$USER/architect-pkg.sh..."
    curl -L -o /home/$USER/architect-pkg.sh https://raw.githubusercontent.com/javilopezdiez/architect/main/architect-pkg.sh
    ( /usr/bin/runuser -u $USER -- /home/$USER/architect-pkg.sh )|& tee 2-user.log

```
