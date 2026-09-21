# tty resolution
```bash
    pacman -S fbset
    /etc/systemd/system/multi-user.target.wants/myfbset.service
```

# login
```bash
    #display manager
    yay -Rnsc lightdm
    yay -S xorg-xinit
    /home/loncelot/.bash_profile # so that after login automatically startx
    ctrl+shift+alt f1,f2,f3 # if i want to go to tty
    ctrl+shift+alt f7 # back to graphical
    bash -i -c # interactive won't work
    /home/loncelot/.bashrc # --> source ~/.bash_aliases ({whateveralias})
    bash -c "-s expand_aliases; source ~/.bash_aliases; eval {whateveralias}";
```

# NETWORK TOINSTALL
```bash
    sudo pacman -S pipewire pipewire-pulse wireplumber alsa-utils pavucontrol
    systemctl --user enable --now pipewire pipewire-pulse wireplumber
    # Network kernel module
    sudo pacman -S broadcom-wl
    # lets me see driver in use
    lspci -k -s 03:00.0
    # remove
    sudo modprobe -r b43 bcma ssb
    sudo modprobe -r wl
    sudo modprobe wl
```

# audio kernel module
```bash
    # https://tanis.codes/posts/macbook-12-audio-on-arch-linux/
        git clone https://github.com/breitburg/macbook12-audio-driver.git
        cd macbook12-audio-driver
        sudo ./install.cirrus.driver.sh -i
        # volume control broken
        https://github.com/leifliddy/macbook12-audio-driver/issues/55
        # FORK
        sudo pacman -S dkms linux-headers
        git clone https://github.com/juicecultus/macbook12-audio-driver.git
        sudo ./install.cirrus.driver.sh -i
        # verification
        lsmod | grep snd_hda_codec_cs420x
        dkms status
        # uninstall
            # auto
            sudo ./install.cirrus.driver.sh -u
            # manual
            sudo rm /lib/modules/$(uname -r)/updates/dkms/snd-hda-codec-cs420x.ko.zst
            sudo rm /lib/modules/$(uname -r)/updates/snd-hda-codec-cs420x.ko*
            sudo depmod -a
            sudo reboot
```

# grub
```bash
    # OK but no
        grub-mkfont -s 30 -o /tmp/FreeMonoBold30.pf2 \
            /usr/share/fonts/gnu-free/FreeMonoBold.otf
        sudo cp /tmp/FreeMonoBold30.pf2 /boot/grub/FreeMonoBold30.pf2
        codes /etc/default/grub
            GRUB_FONT=/boot/grub/FreeMonoBold30.pf2
    # OK
        GRUB_FONT=/boot/grub/fonts/unicode32.pf2
        sudo grub-mkconfig -o /boot/grub/grub.cfg
```

# keyboard swapping and trackpad
```bash
    # keys
        pacman -S keyd
        /etc/keyd/default.conf
    # PalmRejection
        /usr/share/X11/xorg.conf.d/40-libinput.conf
            Section "InputClass"
                    Identifier "Apple SPI Touchpad"
                    MatchIsTouchpad "on"
                    Driver "libinput"
                    Option "DisableWhileTyping" "on"
                    Option "Tapping" "on"
            EndSection
        /usr/share/libinput/local-overrides.quirks
            [Keyd Virtual Keyboard]
            MatchUdevType=keyboard
            MatchName=*keyd*keyboard
            AttrKeyboardIntegration=internal
            [Apple SPI Keyboard]
            MatchUdevType=keyboard
            MatchName=*Apple SPI Keyboard*
            AttrKeyboardIntegration=internal
        # https://github.com/juicecultus/macbook-arch-system
        /etc/libinput/local-overrides.quirks
            [Apple SPI Touchpad (applespi 06cb:0417)]
            MatchUdevType=touchpad
            MatchBus=spi
            MatchVendor=0x06CB
            MatchProduct=0x0417
            AttrSizeHint=104x75
            AttrTouchSizeRange=150:130
            AttrPalmSizeThreshold=1600
            ModelAppleTouchpad=1
```

# Gainerakoak
```bash
    # database locked when yay
    rm ~/.gnupg/public-keys.d/pubring.db.lock
    # mouse
    warpd
    # sleep
    yay -Rnsc light-locker
    yay -S xfce4-screensaver
    # startup sound (mod hex in) mystartupsound.sh
        /sys/firmware/efi/efivars/
    # /home/loncelot/.config/Code/User/theme.css
    # ~/.config/gtk-3.0/gtk.css
    # xfce-term ???
    # theming
        xfconf-query -c xsettings -p /Net/ThemeName
        # Matcha-dark-aliz
        xfconf-query -c xfwm4 -p /general/theme
        # Loncelot -> ~/.themes/Loncelot/xfwm4/themerc
        xfconf-query -c xsettings -p /Gtk/CursorThemeName
        # loncelot -> ~/.icons/ -> /usr/share/icons/loncelot/cursors/* (here are the files)
    #Neovim
    yay -S nerd-fonts-git
    pacman -S tree-sitter-cli                
    sudo pacman -S ripgrep
    sudo pacman -S xclip
    git clone https://github.com/LazyVim/starter ~/.config/nvim
        rm -rf /home/loncelot/.local/state/nvim
        rm -rf /home/loncelot/.local/share/nvim
```
