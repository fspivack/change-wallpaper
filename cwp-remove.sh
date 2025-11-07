#!/bin/bash

# Copyright (c) 2025 Francesca Spivack
# Licensed under the MIT License: https://opensource.org/licenses/MIT

# Remove 'change-wallpaper' program by removing the '.desktop' file from the
# Applications menu and removing the directory containing the state file


DESKTOP_FILE="$HOME/.local/share/applications/cwp.desktop"

if [[ -f "$DESKTOP_FILE" ]]; then
    printf "Removing launcher at %s...\n" "$DESKTOP_FILE"
    rm "$DESKTOP_FILE"
    # Refresh the applications
    update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1
    # Check exit code of previous command
    if [[ ! "$?" -eq 0 ]]; then
        prinf "An error occurred. Exiting script\n" >&2
        exit 1
    fi
else
    printf "No launcher found at %s\n" "$DESKTOP_FILE"
    # We exit without error. UPDATE: not exiting
    # exit 0
fi

# Find the state file directory
if [ -z "$XDG_STATE_HOME" ]; then
    CWP_STATE_DIR="$HOME/.local/state/change-wallpaper"
else
    CWP_STATE_DIR="$XDG_STATE_HOME/change-wallpaper"
fi

if [[ -d "$CWP_STATE_DIR" ]]; then
    printf "Removing state directory at %s...\n" "$CWP_STATE_DIR"
    rm -rf "$CWP_STATE_DIR"
fi
printf "Cleanup complete.\n"

# Find user's config directory location
if [[ -z "$XDG_CONFIG_HOME" ]]; then
    CWP_CONFIG_DIR="$HOME/.config/change-wallpaper"
else
    CWP_CONFIG_DIR="$XDG_CONFIG_HOME/change-wallpaper"
fi

if [[ -d "$CWP_CONFIG_DIR" ]]; then
    printf "If you had the program pinned to your panel, and it hasn't been removed, you may want to remove it.\n"
    printf "You may also want to remove the config directory associated with this program:\n"
    printf "%s\n" "$CWP_CONFIG_DIR"
fi
