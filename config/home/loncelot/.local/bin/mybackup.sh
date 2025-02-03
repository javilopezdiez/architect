#!/bin/bash

DU="Destination of backup"
BU="Backup source files to destination"
GU="Backup source files to git repo"

# Default directories
B="/run/media/$USER/nail/backup"
G="$HOME/Workspace/architect/config"

source_dirs=(
    "$HOME/.profile"
    "$HOME/.bashrc"
    "$HOME/.face"

    # "$HOME/.local/bin"
    "$HOME/.local/bin/mysrc"
    "$HOME/.local/bin/my*.sh"
    "$HOME/.themes"

    "$HOME/.config/xfce4"
    "$HOME/.config/devilspie2"
    # "$HOME/.config/Code/User"
    "$HOME/.config/Code/User/*.json"
    "$HOME/.config/Thunar"
    # "$HOME/.config/autostart/mykeyboard.desktop"
    # "$HOME/.config/autostart/mydevilspie2.desktop"
    "$HOME/.config/autostart/my*.desktop"
    "$HOME/.config/mimeapps.list"
    # "$HOME/.config/myicon"

    "$HOME/Pictures/wallpapers/art/bierstadt"
    "$HOME/Pictures/wallpapers/mybackground.png"

    "/etc/default/grub"
    "/etc/lightdm/lightdm-gtk-greeter.conf"
    # "/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml"
    "/etc/sudoers"
    # "/etc/xdg"

    "/usr/lib/vmware/view/dct/configFiles"
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
                B=$(get_directory_argument "$1")
                echo $DU set to $B
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
                BHOME="$B$HOME"
                direction="restore"
                copy
                exit
                ;;
            -b|--backup)
                echo $BU;
                BHOME="$B$HOME"
                direction="backup"
                copy
                ;;
            -g|--git)
                echo $GU;
                BHOME="$G$HOME"
                direction="backup"
                copy
                ;;
            *)
                usage
                exit 1
                ;;
        esac
        shift
    done
}

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
    echo "  -b, --backup                    $BU"
    echo "  -g, --git                       $GU"
    echo "  -r, --restore                   Restore destination directories to source directories (this will terminate the script after execution)"
    echo "  --help                          Display this help message"
}

copy() {
    echo "The backup files are in: $B"
    if [[ "$direction" == "backup" ]]; then
        for source_dir in "${source_dirs[@]}"; do
            for expanded_source in $source_dir; do
                if [[ "$expanded_source" == $HOME* ]]; then
                    backup_dir="${expanded_source/$HOME/$BHOME}"
                else
                    backup_dir="${B}${expanded_source}"
                fi
                sudo mkdir -p "$(dirname "$backup_dir")"
                if [[ -d "$expanded_source" ]]; then
                    sudo rsync -ah --info=progress2 "$expanded_source/" "$backup_dir"
                else
                    sudo rsync -ah --info=progress2 "$expanded_source" "$backup_dir"
                fi
            done
        done
    elif [[ "$direction" == "restore" ]]; then
        for source_dir in "${source_dirs[@]}"; do
            for expanded_source in $source_dir; do
                if [[ "$expanded_source" == $HOME* ]]; then
                    backup_dir="${expanded_source/$HOME/$BHOME}"
                else
                    backup_dir="${B}${expanded_source}"
                fi
                sudo mkdir -p "$(dirname "$expanded_source")"
                if [[ -d "$backup_dir" ]]; then
                    sudo rsync -ah --info=progress2 "$backup_dir/" "$expanded_source"
                else
                    sudo rsync -ah --info=progress2 "$backup_dir" "$expanded_source"
                fi
            done
        done
    else
        usage
    fi
}

# Execute the main function
main "$@"