# 🌲 Spruce Forest Theme for Linux

![Spruce Forest Theme Preview](spruce-forest-theme/previews/preview.png)

> A beautifully crafted Linux theme package featuring a serene spruce forest aesthetic with elegant widgets and customization options

## 🎯 Features

- **Complete Theme Pack** with coordinated elements
- **Custom Conky Widgets** - CPU, RAM, disk, and time displays
- **Cross-DE Compatibility** - Works on GNOME, XFCE, KDE, and more
- **One-Click Installation** - Automated setup script
- **Multiple Wallpapers** - Choose from 3 stunning spruce forest backgrounds
- **Dark/Light Variants** - We10X and We10X-dark icon themes

## 📦 What's Included

| Component         | Options                                  |
|-------------------|------------------------------------------|
| GTK Themes        | Lavanda-Sea-Dark (+hdpi/xhdpi variants)  |
| Icon Packs        | We10X, We10X-dark                        |
| Wallpapers        | 3 spruce forest variants (1920x1080)     |
| Conky Widgets     | Time, CPU, Memory, Disk, Processes       |
| Fonts             | 10 premium fonts included                |

## 🚀 Installation

### Automated Installer
```bash
# Clone the repository
git clone https://github.com/pjprogrammers/linux-customizations

# Run the installer
cd linux-customizations/spruce-forest-theme
chmod +x install-theme.sh
./install-theme.sh
```

### Manual Installation
1. Copy themes to `~/.themes`
2. Copy icons to `~/.icons`
3. Install fonts to `~/.local/share/fonts`
4. Set wallpaper from `wallpapers/` directory
5. Configure Conky using provided widgets

## 🖥️ Desktop Compatibility

| Environment | Themes | Icons | Wallpaper | Widgets |
|-------------|--------|-------|-----------|---------|
| GNOME       | ✅     | ✅    | ✅        | ✅      |
| XFCE        | ✅     | ✅    | ✅        | ✅      |
| KDE Plasma  | ✅     | ✅    | ✅        | ⚠️      |
| Cinnamon    | ✅     | ✅    | ✅        | ✅      |
| MATE        | ✅     | ✅    | ✅        | ✅      |

## 🎨 Customization Options

Edit the `install-theme.sh` configuration section:
```bash
# User-selectable components
SELECTED_WALLPAPER="spruce_forest_2.jpg"  # Options: 1, 2, or 3
SELECTED_GTK_THEME="Lavanda-Sea-Dark"     # Use any theme in themes/
SELECTED_ICON_THEME="We10X"               # Options: We10X or We10X-dark
```

## 📸 Preview

### Wallpaper Options
| spruce_forest_1.jpg | spruce_forest_2.jpg | spruce_forest_3.jpg |
|---------------------|---------------------|---------------------|
| ![Wallpaper 1](spruce-forest-theme/wallpapers/spruce_forest_1.jpg) | ![Wallpaper 2](spruce-forest-theme/wallpapers/spruce_forest_2.jpg) | ![Wallpaper 3](spruce-forest-theme/wallpapers/spruce_forest_3.jpg) |

### Video Demonstration
[![Theme Demo Video](https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

## ⚙️ Dependencies

The installer will automatically handle:
- `git`
- `conky` (conky-all on Debian-based systems)
- `gsettings` (GNOME)
- `xfconf-query` (XFCE)

## 🤝 Contributing

We welcome contributions! To add your own theme pack:
1. Fork this repository
2. Create a new folder under `linux-customizations/` with your theme name
3. Follow the same structure as spruce-forest-theme
4. Submit a pull request

## 📜 License

MIT License - See [LICENSE](LICENSE) for full details

---

**Created with ❤️ by pjprogrammers**  
[GitHub Profile](https://github.com/pjprogrammers) | 
[Report Issues](https://github.com/pjprogrammers/linux-customizations/issues)
