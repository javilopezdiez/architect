#!/bin/bash

backup_string="Backup source files to destination"
git_string="Backup source files to git repo"

# Default directories
backup_directory="/run/media/$USER/nail/backup"
	# I made the disk with a label like this
		# sudo fdisk /dev/mmcblk0
			# d -> all the partitions
			# n -> 1 partition deleting signature
			# w write changes
		# sudo mkfs.ext4 -L nail /dev/mmcblk0p1
git_directory="$HOME/Workspace/architect/config"

file_patterns=(
	# TODO cargo already in .bashrc
	# "$HOME/.profile"

	"$HOME/.bashrc"
	"$HOME/.local/bin/my*"

	"$HOME/.config/xfce4"
	"$HOME/.config/devilspie2"
	"$HOME/.config/Code/User/*.json"
	"$HOME/.config/Thunar"
	"$HOME/.config/autostart/my*.desktop"
	"$HOME/.config/mimeapps.list"

	"$HOME/.face"
	"$HOME/.themes"
	"$HOME/Pictures/wallpapers/art/bierstadt"
	"$HOME/Pictures/wallpapers/mybackground.png"

	# TODO ownership root
	# might it be sudo chmod 440 /etc/sudoers
	"/etc/sudoers"

	# TODO if changes mkconfig
	"/etc/default/grub"

	"/etc/lightdm/lightdm-gtk-greeter.conf"

	"/usr/share/backgrounds/my-lockscreen.jpeg"
	"/usr/share/backgrounds/xfce/xfce-shapes.svg"
	"/usr/share/backgrounds/xfce/xfce-x.svg"
)

main() {
	if ! command -v rsync &> /dev/null; then
		echo "rsync is not installed. Installing..."
		if ! sudo pacman -S rsync; then
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
			if [[ "$direction" == "restore" ]]; then
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
				assignPrivileges loncelot "$path" "$backup_path"
			elif [[ "$direction" == "restore" ]]; then
				copy_content "$backup_path" "$path"
				assignPrivileges root "$backup_path" "$path"
			fi
		done
	done
}

# If source is a dir, copy its contents into target
copy_content() {
	source="$1"
	target="$2"
	sudo mkdir -p "$(dirname "$target")"
	if [[ -d "$source" ]]; then
		sudo rsync -ah --info=progress2 "$source/" "$target"
	else
		sudo rsync -ah --info=progress2 "$source" "$target"
	fi
}

assignPrivileges() {
	user="$1"
	source="$2"
	target="$3"
    if [[ "$source" == "/etc/sudoers" || "$target" == "/etc/sudoers" ]]; then
		sudo chown "$user:$user" "$target"
	fi
}


# Execute the main function
main "$@"