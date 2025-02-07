#!/bin/bash
source $HOME/architect/properties.conf

# --- PACMAN
	echo -e "Updating PACMAN..."
	sudo pacman -Syu --noconfirm --needed
	echo -e "Installing PACMAN Base packages..."
	for PKG in "${PACMAN_PKGS[@]}"; do
		echo "INSTALLING PACMAN PKG: ${PKG}..."
		sudo pacman -S "$PKG" --noconfirm --needed
	done
	echo -e "Installing PACMAN Extra packages..."
	for PKG in "${PACMAN_EXTRA_PKGS[@]}"; do
		echo "INSTALLING PACMAN EXTRA PKG: ${PKG}..."
		sudo pacman -S "$PKG" --noconfirm --needed
	done

# --- YAY (AUR Helper)
	echo "Installing YAY (AUR helper)..."
	mkdir /tmp/yay && cd /tmp/yay
	curl -OJ 'https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=yay'  
	makepkg -si --noconfirm
	rm -rf /tmp/yay
	echo -e "Updating YAY..."
	sudo yay -Syu --noconfirm 
	echo -e "Installing YAY packages..."
	for PKG in "${YAY_PKGS[@]}"; do
		echo "INSTALLING YAY PKG: ${PKG}"
		yay -S "$PKG" --noconfirm --needed
	done

# --- PYTHON PACKAGES (Uncomment if needed)
	pip3 install --user \
	    --force-reinstall \
	    --break-system-packages \
	    https://github.com/dlenski/gp-saml-gui/archive/master.zip

	# --- RUST (Uncomment if needed)
	yay -S rust

	# --- Cargo Features (Uncomment if needed)
	cargo install spotify_player --features image

# --- GITHUB SCRIPTS (Optional, based on dependencies)
	DEPENDENCIES=(
		'xorg-xwininfo'                       # Cli tool to get windows info on an X server
		'wmctrl'                              # Cli tool to Control EWMH window manager
		'xdotool'                             # Cli tool for X11 automation
	)
	for PKG in "${DEPENDENCIES[@]}"; do
		yay -S "$PKG" --noconfirm --needed
	done
	wget -O /home/$USERNAME/.local/bin/movescreen.py https://raw.githubusercontent.com/calandoa/movescreen/master/movescreen.py
	chmod +x /home/$USERNAME/.local/bin/movescreen.py

# --- SERVICE ENABLING
	for SVC in "${SERVICES[@]}"; do
		if ! systemctl is-enabled --quiet "$SVC"; then
			sudo systemctl enable "$SVC"
			echo "$SVC enabled..."
		fi
	done

# --- SERVICE DISABLING
	for SVC in "${disable_services[@]}"; do
		if systemctl is-active --quiet "$SVC"; then
			sudo systemctl stop "$SVC"
			echo "$SVC stopped..."
			sudo systemctl disable "$SVC"
			echo "$SVC disabled..."
		fi
	done

# --- PACKAGE REMOVAL
for PKG in "${REMOVE_PKGS[@]}"; do
	if pacman -Q "$PKG" &>/dev/null; then
		yay -Rnsc "$PKG"
		echo "$PKG removed..."
	fi
done