#!/bin/bash

# Copyright (c) 2025 Francesca Spivack
# Licensed under the MIT License: https://opensource.org/licenses/MIT

# todo: Re-write the following:
# Create desktop icon so that you can change wallpaper by clicking

PARENT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

EXEC_FILE="${PARENT_DIR}/change-wallpaper.sh"

ICON_FILE="${PARENT_DIR}/change-wallpaper-icon.svg"
# mkdir -p ~/.local/share/icons/hicolor/scalable/apps
# ICON_DIR="$HOME/.local/share/icons/hicolor/scalable/apps"
# mkdir -p "$ICON_DIR"
# cp "$ICON_FILE" "$ICON_DIR/"
# gtk-update-icon-cache "$HOME/.local/share/icons/hicolor"

desktop_file="$(printf "\
[Desktop Entry]
Type=Application
Name=Change Wallpaper
Comment=A quick way to change wallpaper
Exec=%s
Icon=%s
Terminal=false
Name[en_GB]=Change Wallpaper
" "$EXEC_FILE" "$ICON_FILE")"

mkdir -p "$HOME/.local/share/applications"

# Write to the .desktop file
printf "%s" "$desktop_file" > "$HOME/.local/share/applications/cwp.desktop"
# Just in case it's not executable
chmod u+x "$EXEC_FILE"
chmod u+x "$HOME/.local/share/applications/cwp.desktop"

# Find appropriate directory to put config in
if [ -z "$XDG_CONFIG_HOME" ]; then
    CWP_CONFIG_DIR="$HOME/.config/change-wallpaper"
else
    CWP_CONFIG_DIR="$XDG_CONFIG_HOME/change-wallpaper"
fi
mkdir -p "$CWP_CONFIG_DIR"
CWP_CONFIG_FILE="$CWP_CONFIG_DIR/config"

config_file="\
#!/bin/bash

# Uncomment the following, and replace the paths with the paths to your
# own wallpaper files

# WALLPAPERS=(
#     \"$HOME/Pictures/nonwork.jpg\"
#     \"$HOME/Pictures/work.jpg\"
#     \"$HOME/Pictures/third-wp.jpg\"
# )
"

if [ -f "$CWP_CONFIG_FILE" ]; then
    # Config file exists - ask user for confirmation of overwrite
    printf "Config file already exists\n"
    read -p "Overwrite? (y/N) " yn
    if [[ "$yn" != "Y" && "$yn" != "y" ]]; then
        printf "Not overwriting config file\n"
        exit 0
    fi
fi
printf "%s" "$config_file" > "$CWP_CONFIG_FILE"
printf "Config file written to %s\n" "$CWP_CONFIG_FILE"
printf "Edit this file to set up the program\n"
