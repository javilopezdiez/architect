# AUDIO
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

# mouse
warpd

# database locked when yay
rm ~/.gnupg/public-keys.d/pubring.db.lock
