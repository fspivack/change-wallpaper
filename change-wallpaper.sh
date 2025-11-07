#!/bin/bash

# Copyright (c) 2025 Francesca Spivack
# Licensed under the MIT License: https://opensource.org/licenses/MIT

# If you want to have this available at the touch of a button, pin this to the
# menu bar. UPDATE: This appears to only work on MATE
# On KDE Plasma you can add an icon to the Desktop, which has the same effect

# This file should be executable but, if not, you can make it executable with:
# chmod +x ~/[path to file]/toggle-wallpaper.sh


# Get directory of this script (otherwise it looks in user's current directory)
PARENT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Not following XDG standard for config file location, because it would make it
# too complicated for the user
#CONFIG_FILE="${PARENT_DIR}/cwp-config"
#CONFIG_FILE="/home/fs462/bin/change-wallpaper/cwp-config"

# Find config file
if [ -z "$XDG_CONFIG_HOME" ]; then
    CWP_CONFIG_FILE="$HOME/.config/change-wallpaper/config"
else
    CWP_CONFIG_FILE="$XDG_CONFIG_HOME/change-wallpaper/config"
fi
if [[ ! -f "$CWP_CONFIG_FILE" ]]; then
    printf "ERROR: Config file '%s' not found\n" "$CONFIG_FILE" >&2
    printf "Run 'cwp-make-shortcut.sh' to create config, then edit it" >&2
    exit 1
fi
source "$CWP_CONFIG_FILE"

# Define the state file, using XDG standard
if [ -z "$XDG_STATE_HOME" ]; then
    CWP_STATE_HOME="$HOME/.local/state/change-wallpaper"
else
    CWP_STATE_HOME="$XDG_STATE_HOME/change-wallpaper"
fi
mkdir -p "$CWP_STATE_HOME"

# Path to a tiny state file
STATE_FILE="$CWP_STATE_HOME/.current_wallpaper_state"

# Default state if file doesn't exist
if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
fi

CURRENT_STATE=$(cat "$STATE_FILE")

# Get number of wallpapers, so as to loop through them
numwallpapers="${#WALLPAPERS[@]}"
# Get next wallpaper number, using modular arithmetic
(( next_state = ( CURRENT_STATE + 1 ) % numwallpapers ))
new_wallpaper="${WALLPAPERS[$next_state]}"
# # Change wallpaper
# # dconf write /org/mate/desktop/background/picture-filename "'$new_wallpaper'"
# gsettings set org.mate.background picture-filename "$new_wallpaper"

# Functions to change wallpaper depending on desktop environment
# The argument in each case is the filename

set_mate_wallpaper() {
    gsettings set org.mate.background picture-filename "$1"
}

set_gnome_wallpaper() {
    gsettings set org.gnome.desktop.background picture-uri "file://$1"
}

set_kde_wallpaper() {
    local file="$1"
    # Use 'qdbus' to send a message to the org.kde.plasmashell D-Bus service,
    # executing a JavaScript snippet inside the Plasma scripting environemnt
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
    var allDesktops = desktops();
    for (i = 0; i < allDesktops.length; i++) {
        d = allDesktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = ['Wallpaper', 'org.kde.image', 'General'];
        d.writeConfig('Image', 'file://$file');
    }"
}

set_xfce_wallpaper() {
    # Here we get a list of those settings which relate to desktop background
    # They will always end 'last-image' (I believe)
    mapfile -t wp_array <<< "$(xfconf-query -c xfce4-desktop -l | grep 'last-image$')"
    for el in "${wp_array[@]}"; do
        xfconf-query -c xfce4-desktop -p "$el" -s "$1"
    done
}

set_lxqt_wallpaper() {
    pcmanfm-qt --set-wallpaper "$1"
}

set_lxde_wallpaper() {
    pcmanfm --set-wallpaper "$1"
}

detect_desktop_env() {
    # Detect which desktop environment we're in
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        printf "%s" "$XDG_CURRENT_DESKTOP"
    elif [ -n "$DESKTOP_SESSION" ]; then
        printf "%s" "$DESKTOP_SESSION"
    elif [ -n "$GNOME_DESKTOP_SESSION_ID" ]; then
        printf "GNOME"
    elif [ -n "$MATE_DESKTOP_SESSION_ID" ]; then
        printf "MATE"
    elif [ -n "$KDE_FULL_SESSION" ]; then
        printf "KDE"
    else
        # Not found - assuming GNOME, as it's the most popular
        printf "GNOME"
    fi
}

# Here we get the desktop environment and make it lower-case for consistency
DE=$(detect_desktop_env  | tr '[:upper:]' '[:lower:]')

case "$DE" in
    *mate*)
        set_mate_wallpaper "$new_wallpaper"
        ;;
    *gnome*|*cinnamon*|*unity*)
        set_gnome_wallpaper "$new_wallpaper"
        ;;
    *kde*|*plasma*)
        set_kde_wallpaper "$new_wallpaper"
        ;;
    *xfce*)
        set_xfce_wallpaper "$new_wallpaper"
        ;;
    *lxqt*)
        set_lxqt_wallpaper "$new_wallpaper"
        ;;
    *lxde*)
        set_lxde_wallpaper "$new_wallpaper"
        ;;
    *)
        printf "Unknown desktop environment. Defaulting to GNOME\n" >&2
        set_gnome_wallpaper "$new_wallpaper"
        ;;
esac

# Change state in file
echo "$next_state" > "$STATE_FILE"
