#!/bin/bash
# ========================================================
# Spruce Forest Theme Installer 🌲
# Version: 1.1
# Author: pjprogrammers
# GitHub: https://github.com/pjprogrammers/spruce-forest-theme
# License: MIT
# ========================================================
#
# Description:
# Automated installer for Spruce Forest Theme package.
# Features:
# - Cross-DE compatibility (GNOME, XFCE, KDE)
# - Selective component application
# - Full asset deployment
# - Automatic dependency handling
#
# Usage:
# 1. chmod +x install-theme.sh
# 2. ./install-theme.sh
# ========================================================

# ========================
# CONFIGURATION
# ========================
THEME_NAME="Spruce Forest Theme"
THEME_DIR="$HOME/Documents/spruce-forest-theme"
REPO_URL="https://github.com/pjprogrammers/spruce-forest-theme"

# User-selectable components
SELECTED_WALLPAPER="spruce_forest_1.jpg"     # Options: spruce_forest_{1..3}.jpg
SELECTED_GTK_THEME="Lavanda-Sea-Dark"        # From themes/
SELECTED_ICON_THEME="Flat-Remix-Teal-Dark"   # Must be installed on system

# ========================
# DEPENDENCY MANAGEMENT
# ========================
install_dependencies() {
    echo "🔍 Checking system dependencies..."

    # Map: command → package name
    declare -A pkg_map=( ["git"]="git" ["conky"]="conky-all" )
    local install_cmd=""
    local update_cmd=""
    local missing_pkgs=()

    # Detect package manager
    if command -v apt >/dev/null; then
        update_cmd="sudo apt update"
        install_cmd="sudo apt install -y"
    elif command -v pacman >/dev/null; then
        pkg_map["conky"]="conky"
        update_cmd="sudo pacman -Sy"
        install_cmd="sudo pacman -S --noconfirm"
    elif command -v dnf >/dev/null; then
        pkg_map["conky"]="conky"
        update_cmd="sudo dnf check-update"
        install_cmd="sudo dnf install -y"
    else
        echo "❌ Unsupported package manager."
        return 1
    fi

    # Update package list first
    echo "🔄 Updating package list..."
    $update_cmd

    # Check and collect missing
    for cmd in "${!pkg_map[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_pkgs+=("${pkg_map[$cmd]}")
        fi
    done

    # Install if needed
    if [ "${#missing_pkgs[@]}" -gt 0 ]; then
        echo "📦 Installing: ${missing_pkgs[*]}"
        if ! $install_cmd "${missing_pkgs[@]}"; then
            echo "⚠️ Some packages failed to install."
        fi
    else
        echo "✅ All dependencies are satisfied."
    fi
}

# ========================
# WALLPAPER SETUP
# ========================
set_wallpaper() {
    [ ! -f "$WALLPAPER" ] && return 1

    echo "🖼️ Setting wallpaper: $(basename "$WALLPAPER")"
    if command -v gsettings >/dev/null; then
        gsettings set org.gnome.desktop.background picture-uri-dark "file://$WALLPAPER" 2>/dev/null
        gsettings set org.gnome.desktop.background picture-uri "file://$WALLPAPER" 2>/dev/null
    elif command -v xfconf-query >/dev/null; then
        # Apply wallpaper for all monitors
        for i in {0..4}; do
            xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor$i/image-path -s "$WALLPAPER"
        done
    elif command -v plasma-apply-wallpaperimage >/dev/null; then
        plasma-apply-wallpaperimage "$WALLPAPER" 2>/dev/null
    else
        echo "ℹ️ Manual step: Set wallpaper from: $WALLPAPER"
        return 1
    fi
}

# ========================
# THEME AND ICON SETTINGS
# ========================
apply_theme_settings() {
    echo "🎨 Applying GTK and icon themes..."
    if command -v gsettings >/dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "$SELECTED_GTK_THEME"
        gsettings set org.gnome.desktop.interface icon-theme "$SELECTED_ICON_THEME"
        echo "✅ GTK Theme: $SELECTED_GTK_THEME"
        echo "✅ Icon Theme: $SELECTED_ICON_THEME"
    else
        echo "⚠️ Your desktop may not support automatic theme setting."
    fi
}

# ========================
# INSTALL THEME ASSETS
# ========================
install_assets() {
    echo "📦 Installing theme assets..."

    # Wallpapers
    mkdir -p "$HOME/Pictures/Wallpapers"
    if [ -d "$THEME_DIR/wallpapers" ]; then
        cp -r "$THEME_DIR/wallpapers/"* "$HOME/Pictures/Wallpapers/"
        echo "✅ Wallpapers: ~/Pictures/Wallpapers/"
    fi

    # GTK Themes
    mkdir -p "$HOME/.themes"
    if [ -d "$THEME_DIR/themes" ]; then
        cp -r "$THEME_DIR/themes/"* "$HOME/.themes/"
        echo "✅ GTK Themes: ~/.themes/"
    fi

    # Icons (only message, not included in repo)
    mkdir -p "$HOME/.icons"
    echo "📎 NOTE: Make sure $SELECTED_ICON_THEME is installed in ~/.icons/"

    # Fonts
    mkdir -p "$HOME/.fonts"
    if [ -d "$THEME_DIR/fonts" ]; then
        cp "$THEME_DIR/fonts/"* "$HOME/.fonts/"
        fc-cache -fv >/dev/null
        echo "✅ Fonts: ~/.fonts/"
    fi

    # Set wallpaper after copying
    WALLPAPER="$HOME/Pictures/Wallpapers/$SELECTED_WALLPAPER"
    set_wallpaper
}

# ========================
# MAIN INSTALLATION
# ========================
main() {
    echo -e "\n🌲 \033[1mInstalling $THEME_NAME\033[0m 🌲"
    echo "========================================"

    # 1. Dependencies
    install_dependencies

    # 2. Clone theme repo if not present
    if [ ! -d "$THEME_DIR" ]; then
        echo "📥 Cloning theme repo..."
        if ! git clone "$REPO_URL" "$THEME_DIR"; then
            echo "❌ Failed to clone theme repo."
            exit 1
        fi
    fi

    # 3. Install assets
    install_assets

    # 4. Apply GTK + Icon themes
    apply_theme_settings

    # 5. Conky Autostart
    echo -e "\n🧩 Setting up Conky..."
    AUTOSTART_DIR="$HOME/.config/autostart"
    mkdir -p "$AUTOSTART_DIR"
    if [ -f "$THEME_DIR/scripts/widgets.desktop" ]; then
        cp "$THEME_DIR/scripts/widgets.desktop" "$AUTOSTART_DIR/"
        echo "✅ Conky autostart enabled."
    fi

    # 6. Make launch-conky.sh executable
    if [ -f "$THEME_DIR/scripts/launch-conky.sh" ]; then
        chmod +x "$THEME_DIR/scripts/launch-conky.sh"
        bash -c "sleep 10 && bash \"$THEME_DIR/scripts/launch-conky.sh\"" &
        echo "✅ Conky will launch in 10s."
    fi

    # Done
    echo -e "\n========================================"
    echo -e "🎉 \033[1m$THEME_NAME installed successfully!\033[0m"
    echo -e "🛑 Log out and back in to apply all changes.\n"
}

# ========================
# EXECUTION START
# ========================
main "$@"
