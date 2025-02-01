#/!bin/bash

BASE_PKGS=(
        'nano'                           # Pico editor clone with enhancements

        'xfce4'                          # xfce Package Group for xfce lightweight and modular desktop environment based on GTK
        'nm-connection-editor'           # NetworkManager GUI connection editor and widgets

        'lightdm'                        # Lightweight display manager
        'lightdm-gtk-greeter'            # 

        'extra/network-manager-applet'   # Applet for managing network connection
        'htop'                           # Process viewer
        'screenfetch'                    # CLI Bash script to show system/theme info in screenshots
)

PACMAN_PKGS=(
    # --- Package Managers
        'python-pip'                     # Python Package Manager

    # --- XORG (Something to do with x11)
        # 'xorg'                          # Base Package
        # 'xorg-drivers'                  # Display Drivers
        # 'xorg-server'                   # XOrg server
        # 'xorg-apps'                     # XOrg apps group
        # 'xorg-xinit'                    # XOrg init
        'xorg-xinput'                   # Xorg xinput trackpad / configure devices
        # 'mesa'                          # Open source version of OpenGL

    # --- Thinkpad SETUP
        # 'dockd'
        # 'xorg-xbacklight'               # Display and brightness thinkpad
        # 'xf86-input-synaptics'          # Trackpad thinkpad
        # 'intel-opencl-runtime'
        # 'intel-virtual-output'
        # 'intel-compute-runtime'
        # 'acpi'

    # --- Other Desktop SETUP
        # 'awesome'                       # Awesome Desktop
        # 'xfce4-power-manager'           # Power Manager
        # 'acpi'
        # 'rofi'                          # Menu System
        # 'picom'                         # Translucent Windows
        # 'compton'                       # Transparency
        # 'xclip'                         # System Clipboard
        # 'polkit'                        # Elevate Applications
        # 'gnome-keyring'                 # Password Saving
        # 'lxappearance'                  # Set System Themes
        # 'flameshot'                     # Screenshots
        # 'materia-theme'
        # 'materia-gtk-theme'             # Desktop Theme
        # 'papirus-icon-theme'            # Desktop Icons
        # 'capitaine-cursors'             # Cursor Themes
        # 'nautilus'                      # Filesystem browser
        # 'pcmanfm'                       # Filesystem browser
        # 'nitrogen'                      # Wallpaper changer
        # 'xorg-xrandr'                   # Screen output
        # 'arandr'                        # Visual front end for xrandr
        'tlp'                           # Battery saving command line utility
        'auto-cpufreq'                  # Automatic CPU speed & power optimizer
        'cpupower'                      # Kernel tool for tunning cpu power saving
        # 'neofetch'                      # A CLI system information tool

    # --- Lock - Login SETUP
        # 'i3lock'                        # Screen locker
        # 'i3lock-fancy-git'
        # 'lightdm-webkit2-greeter'       # Framework for Awesome Login Themes
        # 'lightdm-slick-greeter'
        # 'lightdm-webkit-theme-aether'   # Lightdm Login Theme - https://github.com/NoiSek/Aether#installation
        # 'xscreensaver'                  # Screen saver and locker for the X Window System

    # --- Networking SETUP
        # 'wpa_supplicant'                # Key negotiation for WPA wireless networks
        # 'dialog'                        # Enables shell scripts to trigger dialog boxex
        # 'openvpn'                       # Open VPN support
        # 'networkmanager-openvpn'        # Open VPN plugin for NM
        # 'network-manager-applet'        # System tray icon/utility for network connectivity
        # 'libsecret'                     # Library for storing passwords
        # 'samba'                         # Samba File Sharing
        # 'smbclient'                     # SMB connection
        # 'gvfs-smb'                      # SMB Samba connection
        # 'sshfs'                         # FUSE client based on SSH needed by Thunar for SMB
        # 'ipcalc'                        # Utility for network that Calculates IP broadcast, network, Cisco wildcard mask, and host ranges
        # 'nmap'                          # Utility for network discovery and security auditing
        # 'arp-scan'                      # Utility for network discoveru that uses ARP to discover and fingerprint IP hosts on the local network

    # --- Audio SETUP
        # 'alsa-utils'                    # Advanced Linux Sound Architecture (ALSA) Components https://alsa.opensrc.org/
        # 'alsamixer'                     # Volume control
        # 'alsa-plugins'                  # ALSA plugins
        # 'pulseaudio'                    # Pulse Audio sound components
        # 'pulseaudio-alsa'               # ALSA configuration for pulse audio
        # 'pavucontrol'                   # Pulse Audio volume control
        # 'pnmixer'                       # System tray volume control

    # --- Bluetooth SETUP
	    # 'bluez'                         # Daemons for the bluetooth protocol stack
        # 'bluez-utils'                   # Bluetooth development and debugging utilities
        # 'bluez-firmware'                # Firmwares for Broadcom BCM203x and STLC2300 Bluetooth chips
        # 'blueberry'                     # Bluetooth configuration tool
        # 'pulseaudio-bluetooth'          # Bluetooth support for PulseAudio

    # --- System SETUP
        # 'linux-lts'                     # Long term support kernel

    # --- Fonts SETUP
        # 'ttf-google-fonts-git'
        # 'xorg-fonts-100dpi'
        # 'xorg-fonts-75dpi'
        # 'xorg-fonts-alias-75dpi'
        # 'xorg-fonts-alias-100dpi'
        # 'xorg-fonts-alias-cyrillic'
        # 'xorg-fonts-alias-misc'
        # 'xorg-fonts-cyrillic'
        # 'xorg-fonts-encodings'
        # 'xorg-fonts-misc'
        # 'xorg-fonts-type1'
        # 'gsfonts'

    # --- terminal UTILITIES
        # 'openssh'                       # SSH connectivity tools
        # 'unrar'                         # RAR compression program
        # 'unzip'                         # Zip compression program
        # 'p7zip'                         # p7 compression program
        # 'wget'                          # Remote content retrieval
        # 'ranger'                        # File manager
        # 'nnn'                           # File manager
        # 'alacritty'                     # Terminal emulator
        # 'terminator'                    # Terminal emulator
        # 'termite'                       # Terminal emulator
        # 'st'                            # Simple Terminal emulator
	    # 'htop'                          # Process viewer
        # 'screenfetch'                   # System information fancy display
        # 'tree'                          # File directory terminal display
        # 'rtorrent'                      # Torrent manager
        # 'figlet'                        # Banner text generator
        # 'tgpt'                          # Command line chatgpt
        # 'kitty'                         # Terminal emulator with images avaliable (spotify-player)

    # --- development UTILITIES
        # 'github-cli'                    # GitHub’s official command line tool
        # 'atom'                          # Text IDE
        # 'eclipse-java'                  # Java compiler
        # 'android-studio'                # Java compiler
        # 'weka'                          # Machine learning and data minning algorithm collection
        # 'gedit'                         # Text editor
        # 'nodejs'                        # Javascript runtime environment
        # 'npm'                           # Node package manager
        # 'n'                             # Node and Npm package manager
        # 'mongodb-bin'                   # Document oriented database system
        # 'postman-bin'                   # API development collab platform
        # 'openshift-client-bin'          # Kubernetes dristribution of redhat
        # 'rstudio-desktop'               # R programming IDE

    # --- gaming UTILITIES
        # 'lutris'                        # Open Gaming Plataform

    # --- UTILITIES
        # 'chrome-remote-desktop'         # Web browser plugin
        # 'chrome-chrome'                 # Web browser
        # 'tor-browser'                   # Secure Web browser
        # 'brave'                         # Secure Web browser
        # 'sxhkd'                         # Hotkey daemon
        # 'thunderbird'                   # Mail client
        # 'telegram-desktop'              # Chatting client
        # 'whatsapp-nativefier-dark'      # Chatting client
        # 'discord'                       # Chatting calling
        # 'skypeforlinux-stable-bin'      # Videocall / conference
        # 'xpdf'                          # PDF viewer
        # 'okular'                        # PDF viewer
        # 'libreoffice-still'             # Stable office alternative
        # 'multibootusb'                  # Boot multiple live Linux distros
        # 'vlc'                           # Media player
        # 'gimp'                          # GNU image manipulation program
        # 'calibre'                       # Book management
        # 'snapd'                         # Package manager to download icloud
        # 'barrier'                       # Mouse keyboard sharing
        # 'rpi-imager'                    # Raspberry Pi imaging utility

        # 'ytfzf'                         # Youtube comand line client (dependencies bellow)
        # 'fzf'                           # Listing search tool
        # 'youtube-dl'                    # Youtube downloader
        # 'yt-dlp'                        # youtube-dl fork with fixes
        # 'mpv'                           # Open Source media player
        # 'ueberzugpp'                    # Command line images with x11 (optional)
        # 'jq'                            # Command line json processor

        # 'spotifyd'                      # Spotify streaming daemon
        # 'spotify-tui'                   # Spotify client for terminal
        # 'spotify-player'                # Command driven spotify RUST version instead

        # 'yewtube'                       # Youtube comand line client
)

YAY_PKGS=(
    'thorium-browser-bin'           # Web browser
    'visual-studio-code-bin'        # Visual Studio Code
    'vmware-horizon-client'         # Virtual Desktop
    # 'virt-manager'                  # Virtual machine manager
    # 'qemu-base'                     # Virtual machine headless emulator
    # 'remmina'                       # Remote Desktop Client
    # 'freerdp'                      # Remote Desktop Protocol
)

# --- PACMAN
echo -e "\nUpdating PACMAN\n"
sudo pacman -Syu --noconfirm --needed

echo -e "\nInstalling Base packages\n"
for PKG in "${BASE_PKGS[@]}"; do
    echo "INSTALLING PACMAN PKG: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

echo -e "\nInstalling PACMAN packages\n"
for PKG in "${PACMAN_PKGS[@]}"; do
    echo "INSTALLING PACMAN PKG: ${PKG}"
    sudo pacman -S "$PKG" --noconfirm --needed
done

# --- YAY
# AUR helper install
echo "Installing yay AUR helper..."
mkdir /tmp/yay && cd /tmp/yay
curl -OJ 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay'  
makepkg -si --noconfirm
rm -rf /tmp/yay

echo -e "\nUpdating YAY\n"
sudo yay -Syu

echo -e "\nInstalling YAY packages\n"
for PKG in "${YAY_PKGS[@]}"; do
    echo "INSTALLING YAY PKG: ${PKG}"
    yay -S "$PKG" --noconfirm --needed
done

# --- Python Packages
    pip3 install --user \
        --force-reinstall \
        --break-system-packages \
        https://github.com/dlenski/gp-saml-gui/archive/master.zip

# --- RUST
    # yay -S rust
# --- Cargo features export PATH="$PATH:/home/loncelot/.cargo/bin"
    # cargo install spotify_player --features image
    
# --- Github Scripts
    # https://github.com/calandoa/movescreen
        # DEPENDENCIES=(
        #     'xorg-xwininfo'                       # Cli tool to get windows info on an X server
        #     'wmctrl'                              # Cli tool to Control EWMH window manager
        #     'xdotool'                             # Cli tool for X11 automation
        # )
        # for PKG in "${DEPENDENCIES[@]}"; do
        #     yay -S "$PKG" --noconfirm --needed
        # done

        # wget -O ~/.local/bin/movescreen.py https://raw.githubusercontent.com/calandoa/movescreen/master/movescreen.py
        # chmod +x ~/.local/bin/movescreen.py

    # https://github.com/trygveaa/kitty-kitten-search
        # wget -O ~/.config/kitty/scroll_mark.py https://raw.githubusercontent.com/trygveaa/kitty-kitten-search/master/scroll_mark.py
        # wget -O ~/.config/kitty/search.py https://raw.githubusercontent.com/trygveaa/kitty-kitten-search/master/search.py


# Service enabling
sudo systemctl enable lightdm
sudo systemctl enable NetworkManager

# ~/.config
# cp /etc/X11/xinit/xinitrc ~/.xinitrc