#!/usr/bin/env bash

set -euo pipefail

THEME_NAME="Spruce Forest Theme"
THEME_DIR="$HOME/Documents/spruce-forest-theme"
REPO_URL="https://github.com/pjprogrammers/spruce-forest-theme"

SELECTED_WALLPAPER="spruce_forest_1.jpg"
SELECTED_GTK_THEME="Lavanda-Sea-Dark"
SELECTED_ICON_THEME="Flat-Remix-Teal-Dark"

WALLPAPER_DIR="/usr/share/backgrounds/kali-16x9"

install_dependencies() {
    echo "Checking system dependencies..."

    local package_manager=""
    local missing_packages=()

    if command -v apt-get >/dev/null 2>&1; then
        package_manager="apt"
    elif command -v pacman >/dev/null 2>&1; then
        package_manager="pacman"
    elif command -v dnf >/dev/null 2>&1; then
        package_manager="dnf"
    else
        echo "Error: unsupported package manager."
        echo "Supported package managers: apt, pacman, dnf."
        return 1
    fi

    if ! command -v sudo >/dev/null 2>&1; then
        echo "Error: sudo is required to install system packages."
        return 1
    fi

    if ! command -v git >/dev/null 2>&1; then
        missing_packages+=("git")
    fi

    if ! command -v conky >/dev/null 2>&1; then
        case "$package_manager" in
            apt)
                missing_packages+=("conky-all")
                ;;
            pacman|dnf)
                missing_packages+=("conky")
                ;;
        esac
    fi

    if [ "${#missing_packages[@]}" -eq 0 ]; then
        echo "All required dependencies are already installed."
        return 0
    fi

    echo "Installing missing packages: ${missing_packages[*]}"

    case "$package_manager" in
        apt)
            sudo apt-get update
            sudo apt-get install -y "${missing_packages[@]}"
            ;;
        pacman)
            sudo pacman -Sy --needed --noconfirm "${missing_packages[@]}"
            ;;
        dnf)
            sudo dnf makecache
            sudo dnf install -y "${missing_packages[@]}"
            ;;
    esac

    echo "Dependencies installed."
}

clone_or_update_repository() {
    if [ -d "$THEME_DIR/.git" ]; then
        echo "Updating existing theme repository..."

        git -C "$THEME_DIR" pull --ff-only
        return 0
    fi

    if [ -e "$THEME_DIR" ]; then
        echo "Error: $THEME_DIR already exists but is not a Git repository."
        echo "Move or remove that directory and run the installer again."
        return 1
    fi

    echo "Cloning theme repository..."
    git clone "$REPO_URL" "$THEME_DIR"
}

set_wallpaper() {
    local wallpaper="$1"

    if [ ! -f "$wallpaper" ]; then
        echo "Warning: wallpaper not found: $wallpaper"
        return 1
    fi

    echo "Setting wallpaper: $(basename "$wallpaper")"

    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$wallpaper" || true
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper" || true

    elif command -v xfconf-query >/dev/null 2>&1; then
        for monitor in {0..4}; do
            xfconf-query \
                -c xfce4-desktop \
                -p "/backdrop/screen0/monitor${monitor}/image-path" \
                -s "$wallpaper" 2>/dev/null || true
        done

    elif command -v plasma-apply-wallpaperimage >/dev/null 2>&1; then
        plasma-apply-wallpaperimage "$wallpaper"

    else
        echo "No supported desktop wallpaper utility was found."
        echo "Set the wallpaper manually from:"
        echo "  $wallpaper"
        return 1
    fi
}

install_assets() {
    echo "Installing theme assets..."

    if [ -d "$THEME_DIR/wallpapers" ]; then
        echo "Installing wallpapers to $WALLPAPER_DIR..."

        sudo mkdir -p "$WALLPAPER_DIR"
        sudo cp -r "$THEME_DIR/wallpapers/." "$WALLPAPER_DIR/"

        echo "Wallpapers installed."
    else
        echo "Warning: wallpaper directory not found:"
        echo "  $THEME_DIR/wallpapers"
    fi

    if [ -d "$THEME_DIR/themes" ]; then
        mkdir -p "$HOME/.themes"
        cp -r "$THEME_DIR/themes/." "$HOME/.themes/"

        echo "GTK themes installed to:"
        echo "  $HOME/.themes"
    else
        echo "Warning: theme directory not found:"
        echo "  $THEME_DIR/themes"
    fi

    mkdir -p "$HOME/.icons"

    if [ -d "$HOME/.icons/$SELECTED_ICON_THEME" ]; then
        echo "Icon theme found: $SELECTED_ICON_THEME"
    else
        echo "Note: $SELECTED_ICON_THEME is not included in this repository."
        echo "Install it separately if it is not already installed."
    fi

    if [ -d "$THEME_DIR/fonts" ]; then
        mkdir -p "$HOME/.fonts"
        cp -r "$THEME_DIR/fonts/." "$HOME/.fonts/"

        if command -v fc-cache >/dev/null 2>&1; then
            fc-cache -fv >/dev/null
        fi

        echo "Fonts installed to:"
        echo "  $HOME/.fonts"
    fi

    local wallpaper="$WALLPAPER_DIR/$SELECTED_WALLPAPER"

    set_wallpaper "$wallpaper" || true
}

apply_theme_settings() {
    if ! command -v gsettings >/dev/null 2>&1; then
        echo "GTK and icon theme settings were not changed automatically."
        echo "Automatic theme selection is currently configured for GNOME."
        return 0
    fi

    echo "Applying GTK and icon themes..."

    if ! gsettings set org.gnome.desktop.interface gtk-theme "$SELECTED_GTK_THEME"; then
        echo "Warning: failed to apply GTK theme: $SELECTED_GTK_THEME"
    fi

    if ! gsettings set org.gnome.desktop.interface icon-theme "$SELECTED_ICON_THEME"; then
        echo "Warning: failed to apply icon theme: $SELECTED_ICON_THEME"
    fi

    echo "GTK theme: $SELECTED_GTK_THEME"
    echo "Icon theme: $SELECTED_ICON_THEME"
}

setup_conky() {
    local autostart_dir="$HOME/.config/autostart"
    local widgets_desktop="$THEME_DIR/scripts/widgets.desktop"
    local launch_script="$THEME_DIR/scripts/launch-conky.sh"

    echo "Setting up Conky..."

    mkdir -p "$autostart_dir"

    if [ -f "$widgets_desktop" ]; then
        cp "$widgets_desktop" "$autostart_dir/"
        echo "Conky autostart enabled."
    else
        echo "Warning: widgets.desktop not found."
    fi

    if [ -f "$launch_script" ]; then
        chmod +x "$launch_script"

        (
            sleep 10
            "$launch_script"
        ) &

        echo "Conky will launch in 10 seconds."
    else
        echo "Warning: launch-conky.sh not found."
    fi
}

main() {
    echo
    echo "Installing $THEME_NAME"
    echo "========================================"

    install_dependencies
    clone_or_update_repository
    install_assets
    apply_theme_settings
    setup_conky

    echo
    echo "========================================"
    echo "$THEME_NAME installed successfully."
    echo
    echo "Log out and back in if some desktop changes are not immediately visible."
}

main "$@"
