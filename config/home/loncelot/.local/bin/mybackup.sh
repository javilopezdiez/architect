#!/bin/bash

username="loncelot"
backup_string="Backup source files to destination"
git_string="Backup source files to git repo"

# Default directories
backup_directory="/run/media/$username/nail/backup"
	# I made the disk with a label like this
		# sudo fdisk /dev/mmcblk0
			# d -> all the partitions
			# n -> 1 partition deleting signature
			# w write changes
		# sudo mkfs.ext4 -L nail /dev/mmcblk0p1
git_directory="$HOME/Workspace/architect/config"

file_patterns=(
	"$HOME/.bashrc"
	"$HOME/.local/bin/my*"
	# "$HOME/.local/share/applications"
	"$HOME/.local/share/xfce4/helpers/custom-WebBrowser.desktop"

	"$HOME/.config/xfce4"
	"$HOME/.config/autostart/my*.desktop"
	"$HOME/.config/mimeapps.list"
	"$HOME/.config/devilspie2"
	"$HOME/.config/Code/User/*.json"
	"$HOME/.config/Thunar"

	"$HOME/.Xmodmap"
	"$HOME/.face"
	"$HOME/.themes"
	"$HOME/Pictures/ico"
	"$HOME/Pictures/wallpapers/art/bierstadt"
	"$HOME/Pictures/wallpapers/art/kasmeneo"
	"$HOME/Pictures/wallpapers/arch"
	# "$HOME/Pictures/wallpapers/mybackground.png"

	"/etc/sudoers"
	"/etc/profile.d/home-local-bin.sh"
	"/etc/default/grub"
	# "/etc/grub.d/10_linux"
	"/etc/lightdm/lightdm-gtk-greeter.conf"
	"/etc/X11/xorg.conf.d/10-modesetting.conf"

	# "/boot/grub/themes/Primitivistical"

	"/usr/share/backgrounds/my-*"
	"/usr/share/backgrounds/xfce/xfce-shapes.svg"
	"/usr/share/backgrounds/xfce/xfce-x.svg"

	"$HOME/.vmware/view-preferences"
	# "$HOME/.local/share/lutris/games/turtle-wow-1172-1740406132.yml"
)

main() {
	if ! command -v rsync &> /dev/null; then
		echo "rsync is not installed. Installing..."
		if ! sudo pacman -S rsync --noconfirm; then
			echo "Failed to install rsync. Exiting."
			exit 1
		fi
	fi
	parameters "$@"
}

parameters() {
	dirParameter $@
	actionParameters $@
}
dirParameter() {
	# Resetting the dir in case there is
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-d*|--directory*)
				backup_directory=$(get_directory_argument "$1")
				echo Backup directory set to $backup_directory
				;;
			-r|--restore);;
			-b|--backup);;
			-g|--git);;
			*)
				usage
				exit 1
				;;
		esac
		shift
	done
}
actionParameters() {
	# Copying
	while [[ $# -gt 0 ]]; do
		case "$1" in
			-d*|--directory*)
				;;
			-r|--restore)
				direction="restore"
				copy $backup_directory
				exit
				;;
			-b|--backup)
				echo $backup_string;
				direction="backup"
				copy $backup_directory
				;;
			-g|--git)
				echo $git_string;
				direction="backup"
				copy $git_directory
				;;
			*)
				usage
				exit 1
				;;
		esac
		shift
	done
}

# Returns the directory in d=directory
get_directory_argument() {
	if [[ "$1" == *"="* ]]; then
		echo "${1#*=}"
	else
		usage
		exit 1
	fi
}

usage() {
	echo "Usage: $0 [-b|-g|-r]"
	echo ""
	echo "  -d, --destination=<directory>   Specify the directory to use for backup or restore."
	echo "                                  The directory should be provided in the format: -d=<directory>"
	echo "  -b, --backup                    $backup_string"
	echo "  -g, --git                       $git_string"
	echo "  -r, --restore                   Restore destination directories to source directories (this will terminate the script after execution)"
	echo "  --help                          Display this help message"
}

copy() {
	location="$1"
	locationHOME="$location$HOME"

	echo "The files will be backed up/restored from/to: $location"
	for file_pattern in "${file_patterns[@]}"; do
		# Expand file patterns to match actual files (e.g., *.extension)
		for full_path in $file_pattern; do
			# Get parent directory from full file path when restoring/*.extension
			if [[ "$direction" == "restore" && "$file_pattern" == *\** ]]; then
				path="${full_path%/*}"
			else
				path=$full_path
			fi
			# Substitude HOME for locationHOME
			if [[ "$path" == $HOME* ]]; then
				backup_path="${path/$HOME/$locationHOME}"
			else
				backup_path="${location}${path}"
			fi
			if [[ "$direction" == "backup" ]]; then
				copy_content "$path" "$backup_path"
				set_sudoers_owner $username "$backup_path"
			elif [[ "$direction" == "restore" ]]; then
				set_sudoers_owner root "$backup_path"
				copy_content "$backup_path" "$path"
				# ~/ vs /etc vs /usr
				if [[ "$path" == "$HOME"* ]]; then
					# echo "sudo chown -R $username:$username $path"
					sudo chown -R "$username:$username" "$path"
				fi
				# If restored from parent stop directory copying
				if [[ "$file_pattern" == *\** ]]; then
					break
				fi
			fi
		done
	done
}

# If source is a dir, copy its contents into target
copy_content() {
	source="$1"
	target="$2"
	create_dir $target
	if [[ -d "$source" ]]; then
		sudo rsync -ah --no-owner --info=progress2 "$source/" "$target"
		# echo "Source: $source/"
	else
		sudo rsync -ah --no-owner --info=progress2 "$source" "$target"
		# echo "Source: $source"
	fi
	# echo "Target: $target"
}

create_dir() {
	if [[ "$target" == "$HOME"* ]]; then
		mkdir -p "$(dirname "$target")"
	else
		sudo mkdir -p "$(dirname "$target")"
	fi
}

# Add here root directories so that they can be 
# added in git as user
# restored as root
# Asign ownership 
	# user -> backup
	# root -> system
set_sudoers_owner() {
	u="$1"
	target="$2"
	if [[ "$target" == *"/etc/sudoers" ]]; then
		# echo "sudo chown "$u:$u" "$target""
		sudo chown "$u:$u" "$target"
	fi
}

# Execute the main function
main "$@"