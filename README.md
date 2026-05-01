# 🤖 DexLinux - Mobile Linux Desktop 🐧

**DexLinux** is a powerful and premium script designed to transform your Android device into a professional Linux Desktop environment using Termux. It automates the setup of Termux-X11, XFCE4, GPU acceleration, and multiple Linux distributions with a focus on aesthetics and performance.

---

## ✨ Key Features

- **🚀 One-Click Setup**: Full automation of the Termux-X11 environment and desktop configuration.
- **🎨 Distro-Specific Aesthetics**: Unique themes, icons, and layouts for each distribution (Ubuntu, Arch, Fedora, Debian, Deepin).
- **🎮 GPU Acceleration**: Automatic setup for Turnip/Zink drivers (Native OpenGL 4.6 & GLES 3.2 support).
- **🔊 PulseAudio Integration**: Low-latency audio support for multimedia and apps.
- **📁 Android Integration**: Automatic symlinks to your local storage (Downloads, Photos, Documents).
- **🖥️ Desktop Wallpapers**: Automated installation of high-quality wallpapers curated for each distro.
- **🌗 Visual Consistency**: Seamless theme synchronization between the base desktop and PRoot applications.
- **🔧 Maintenance Menu**: Built-in tools to remove distros, clean cache, and fix permissions easily.

---

## 📦 Supported Distributions

| Distro | Aesthetic Style | Default Layout |
| :--- | :--- | :--- |
| **Ubuntu** | Yaru / Orchis Orange | Left-side Unity Dock |
| **Arch Linux** | Nord / Minimal Grey | Slim Top Bar |
| **Fedora** | Clean Blue / Workstation | GNOME-style Top Bar |
| **Deepin** | Glassmorphism / Beautiful | Centered Bottom Dock |
| **Debian** | Classic / Professional | Standard Bottom Taskbar |

---

## 🚀 Installation

Open **Termux** and execute the following command:

```bash
curl -sL https://raw.githubusercontent.com/luigifaria88/DexLinux/main/DexLinux.sh | bash
```

### Installation Modes:
1. **Full Installation**: The complete experience with extra apps and selected PRoot distro.
2. **Minimal Installation**: A lightweight XFCE core for high performance.
3. **Custom Installation**: Hand-pick every component you need.

---

## 🛠️ Usage & Commands

After installation, use these commands in Termux or the shortcuts on your desktop:

- **Start Desktop**: `bash ~/start-dexlinux.sh`
- **Stop Desktop**: `bash ~/stop-dexlinux.sh`
- **Resolution**: `bash ~/dex-res.sh`
- **Quick Tools**: `bash ~/dex-tools.sh`
- **Maintenance**: Run `DexLinux.sh` and select `M` for the Maintenance Menu.

### Launching Procedure:
1. Open the **Termux:X11** application.
2. Return to **Termux** and run `bash ~/start-dexlinux.sh`.
3. Switch back to **Termux:X11** and enjoy!

---

## ⚠️ Requirements

- **Termux**: [Download from F-Droid](https://f-droid.org/en/packages/com.termux/) (Google Play version is outdated).
- **Termux:X11**: [Download latest APK](https://github.com/termux/termux-x11/actions) from GitHub Actions or nightly builds.
- **Termux:Widget**: (Optional) For Android home screen shortcuts.

### 🛡️ Android 12+ (Phantom Process Killer)
On Android 12 and newer, the system aggressively kills background processes (like your Linux session). To fix this, you **must** run these commands via ADB:

1.  **Enable Developer Options**: Go to `Settings > About Phone` and tap `Build Number` 7 times.
2.  **Enable USB Debugging**: In `Developer Options`, turn on `USB Debugging`.
3.  **Run from a PC (ADB)**:
    *   Download **Android Platform Tools**: [Windows](https://dl.google.com/android/repository/platform-tools-latest-windows.zip) | [Mac](https://dl.google.com/android/repository/platform-tools-latest-darwin.zip) | [Linux](https://dl.google.com/android/repository/platform-tools-latest-linux.zip)
    *   Extract the ZIP and run:
    ```bash
    adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
    adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
    adb shell settings put global settings_enable_monitor_phantom_procs false
    ```
4.  **No PC? (Wireless Debugging)**: Use an app like [LADB](https://play.google.com/store/apps/details?id=com.draco.ladb) or Termux's own `adb` package to run the commands locally via Wireless Debugging.

- **Storage**: 5GB - 15GB of free space recommended for a full experience.

---

## 🤝 Credits & Aesthetics
- **Themes**: [Orchis](https://github.com/vinceliuice/Orchis-theme) by Vinceliuice.
- **Icons**: [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme), [Fluent](https://github.com/vinceliuice/Fluent-icon-theme), and [WhiteSur](https://github.com/vinceliuice/WhiteSur-icon-theme).
- **Core**: Built on the amazing work of the Termux and Termux-X11 communities.
- **Phantom Process Killer**: [ThamSkai](https://github.com/ThamSkai/Termux-Phantom-Process-Killer).

---

**Developed with ❤️ by LuigiFaria88**
