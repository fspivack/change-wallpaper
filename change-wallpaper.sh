#!/bin/bash

# Copyright (c) 2025-2026 Francesca Spivack
# Licensed under the MIT License: https://opensource.org/licenses/MIT

# If you want to have this available at the touch of a button, pin this to the
# menu bar. UPDATE: This appears to only work on MATE
# On KDE Plasma you can add an icon to the Desktop, which has the same effect

# This file should be executable but, if not, you can make it executable with:
# chmod +x ~/[path to file]/toggle-wallpaper.sh


# Get directory of this script (otherwise it looks in user's current directory)
PARENT_DIR=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

# Find config file
if [[ -z "$XDG_CONFIG_HOME" ]]; then
    CWP_CONFIG_FILE="$HOME/.config/change-wallpaper/config"
else
    CWP_CONFIG_FILE="$XDG_CONFIG_HOME/change-wallpaper/config"
fi

# Define the state file, using XDG standard
if [[ -z "$XDG_STATE_HOME" ]]; then
    CWP_STATE_HOME="$HOME/.local/state/change-wallpaper"
else
    CWP_STATE_HOME="$XDG_STATE_HOME/change-wallpaper"
fi

# Path to a tiny state file
STATE_FILE="$CWP_STATE_HOME/.current_wallpaper_state"
# Path to error log (in state directory)
ERROR_LOG="$CWP_STATE_HOME/error.log"

log_error() {
    # Log error to file and also to stderr
    local msg="$1"
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    # Use $2 if it exists, otherwise "ERROR"
    # Do this so that we can specify, e.g., "WARNING" rather than "ERROR"
    local loglevel="${2:-ERROR}"
    
    # Send to stderr
    printf "%s: %s\n" "$loglevel" "$msg" >&2
    
    # Send to the log state file with a timestamp
    printf "[%s] %s: %s\n" "$timestamp" "$loglevel" "$msg" >> "$ERROR_LOG"
}
print_hint() {
    # Only prints to stderr
    printf "%s\n" "$1" >&2
}

load_config() {
    if [[ ! -f "$CWP_CONFIG_FILE" ]]; then
        log_error "Config file '$CWP_CONFIG_FILE' not found"
        print_hint "Run 'cwp-setup.sh' to create config, then edit it"
        return 1
    fi
    
    # Check if it's the old Bash style config
    if grep -q "WALLPAPERS=(" "$CWP_CONFIG_FILE"; then
        source "$CWP_CONFIG_FILE"
        readonly WALLPAPERS
    else
        # New text format
        mapfile -t WALLPAPERS < <(grep -v '^#' "$CWP_CONFIG_FILE" | grep -v '^$')
    fi
}

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
    if [[ -n "$XDG_CURRENT_DESKTOP" ]]; then
        printf "%s" "$XDG_CURRENT_DESKTOP"
    elif [[ -n "$DESKTOP_SESSION" ]]; then
        printf "%s" "$DESKTOP_SESSION"
    elif [[ -n "$GNOME_DESKTOP_SESSION_ID" ]]; then
        printf "GNOME"
    elif [[ -n "$MATE_DESKTOP_SESSION_ID" ]]; then
        printf "MATE"
    elif [[ -n "$KDE_FULL_SESSION" ]]; then
        printf "KDE"
    else
        # Not found - assuming GNOME, as it's the most popular
        printf "GNOME"
    fi
}

main() {
    mkdir -p "$CWP_STATE_HOME"

    # Default state if file doesn't exist
    if [[ ! -f "$STATE_FILE" ]]; then
        echo "0" > "$STATE_FILE"
    fi

    load_config || return 1

    CURRENT_STATE=$(cat "$STATE_FILE")

    # Get number of wallpapers, so as to loop through them
    numwallpapers="${#WALLPAPERS[@]}"
    # Get next wallpaper number, using modular arithmetic
    # Note that if something's gone wrong and the state file exists but is
    # blank, this will just give "1"
    (( next_state = ( CURRENT_STATE + 1 ) % numwallpapers ))
    new_wallpaper="${WALLPAPERS[$next_state]}"

    # Functions to change wallpaper depending on desktop environment
    # The argument in each case is the filename
    
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
}
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
    exit $?
else
    main
fi
