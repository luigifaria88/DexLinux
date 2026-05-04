# 🤖 DexLinux - Mobile Linux Desktop 🐧

**DexLinux** is a powerful and premium script designed to transform your Android device into a professional Linux Desktop environment using Termux. It automates the setup of Termux-X11, XFCE4, GPU acceleration, and multiple Linux distributions with a focus on aesthetics and performance.

---

## ✨ Key Features

- **🚀 One-Click Setup**: Full automation of the Termux-X11 environment and desktop configuration.
- **🎨 Premium Aesthetics**: Orchis Dark GTK theme + Papirus Dark icons applied natively across the entire desktop and PRoot environments.
- **🎮 GPU Acceleration**: Automatic detection and setup for Adreno (Turnip/Freedreno), Mali, PowerVR, and software fallback — supporting OpenGL 4.6 & GLES 3.2 via Zink.
- **🔊 PulseAudio Integration**: Low-latency audio with TCP module for seamless audio forwarding to PRoot subsystems.
- **📁 Android Integration**: Automatic symlinks on the desktop to Downloads, Photos, and Documents from local storage.
- **🔒 Root-Aware**: Auto-detects root access and applies Phantom Process Killer fixes automatically on Android 12+.
- **🖥️ Multi-Display Ready**: XFCE power manager configured in presentation mode with DPMS disabled for external monitor/projection support.
- **🔧 Maintenance Menu**: Built-in tools to remove distros, clean cache, fix permissions, and reset display resolution.
- **📐 Resolution Manager**: Quick resolution changer with presets (Native, 720p, 900p, 1080p, Zoom+, Zoom−).
- **🧰 Quick Tools**: Integrated utility menu for desktop control, resolution management, and GPU status checks.

---

## 📦 Supported PRoot Distributions

| Distro         | Package Manager | Notes                                           |
| :------------- | :-------------- | :---------------------------------------------- |
| **Ubuntu**     | apt             | Recommended — full locale & theme support       |
| **Debian**     | apt             | Stable alternative with same setup path         |
| **Arch Linux** | pacman          | Bleeding edge — `shadow` package for user mgmt  |
| **Fedora**     | dnf             | Workstation — `glibc-all-langpacks` for locales |

> All PRoot distributions receive automatic theme/icon synchronization, GPU environment variables, locale configuration, and GTK settings injection.

---

## 📱 Available Applications

The interactive app selector allows toggling each application individually:

| #   | Application      | Package                 | Category                   |
| :-- | :--------------- | :---------------------- | :------------------------- |
| 1   | **Firefox**      | `firefox`               | Browser (default selected) |
| 2   | **Chromium**     | `chromium`              | Browser                    |
| 3   | **VS Code**      | `code-oss`              | Editor                     |
| 4   | **GIMP**         | `gimp`                  | Image Editor               |
| 5   | **VLC**          | `vlc`                   | Media Player               |
| 6   | **LibreOffice**  | `libreoffice`           | Office Suite (PRoot only)  |
| 7   | **Inkscape**     | `inkscape`              | Vector Graphics            |
| 8   | **btop**         | `btop`                  | System Monitor             |
| 9   | **Wine + Box64** | `wine-stable` + `box64` | Windows App Emulation      |

> LibreOffice (option 6) is installed inside the PRoot environment when selected. Inkscape and btop are installed in both Termux and PRoot when applicable.

---

## 🚀 Installation

Open **Termux** and execute the following command:

```bash
curl -sL https://raw.githubusercontent.com/luigifaria88/DexLinux/main/DexLinux.sh | bash
```

### Installation Modes

| Mode               | Description                                       | Extra Apps         | PRoot               |
| :----------------- | :------------------------------------------------ | :----------------- | :------------------ |
| **1) Full**        | Complete experience with all extras               | Prompted           | Yes (select distro) |
| **2) Minimal**     | Core XFCE desktop only — maximum performance      | None               | No                  |
| **3) Custom**      | Hand-pick apps and choose whether to enable PRoot | Interactive toggle | Optional            |
| **M) Maintenance** | Access maintenance tools without reinstalling     | —                  | —                   |

---

## 🛠️ Usage & Commands

After installation, use these commands in Termux or the shortcuts on your desktop:

| Command                             | Description                                  |
| :---------------------------------- | :------------------------------------------- |
| `bash ~/start-dexlinux.sh`          | Start the desktop session                    |
| `bash ~/stop-dexlinux.sh`           | Gracefully stop the desktop and all services |
| `bash ~/dex-res.sh`                 | Change screen resolution                     |
| `bash ~/dex-tools.sh`               | Open quick tools menu                        |
| `bash ~/dexlinux-shell-<distro>.sh` | Open a PRoot shell for the installed distro  |

### Launching Procedure

1. Open the **Termux:X11** application.
2. Return to **Termux** and run `bash ~/start-dexlinux.sh`.
3. Switch back to **Termux:X11** and enjoy!

### Desktop Shortcuts Created

- **Firefox** (if selected) — browser launcher
- **Display Settings** — resolution changer
- **DexTools** — quick system tools
- **Shutdown DexLinux** — stop desktop session
- **\<Distro\> Shell** (if PRoot enabled) — terminal into PRoot environment
- **Android Widget** — `Start_DexLinux` shortcut for Termux:Widget

---

## 🔧 Maintenance Menu

Accessible via option `M` from the main menu:

| Option                      | Action                                                       |
| :-------------------------- | :----------------------------------------------------------- |
| **1) Remove Distribution**  | List and remove installed PRoot distros                      |
| **2) Clean Package Cache**  | Run `pkg clean` + `apt autoremove` to free space             |
| **3) Fix XFCE Permissions** | Repair executable permissions on start scripts and shortcuts |
| **4) Reset Resolution**     | Delete saved resolution config (safe mode)                   |

---

## 🎮 GPU Acceleration Details

DexLinux auto-detects your GPU hardware and configures the optimal driver stack:

| GPU Type       | Driver               | Detection Method                                    |
| :------------- | :------------------- | :-------------------------------------------------- |
| **Adreno**     | Freedreno (Turnip)   | `ro.hardware.egl` or brand-based heuristic          |
| **Mali / ARM** | Zink (System Vulkan) | EGL vendor or brand detection (Huawei, Honor, etc.) |
| **PowerVR**    | Zink (System Vulkan) | EGL vendor detection                                |
| **Other HW**   | Zink (System Vulkan) | Fallback for unrecognized hardware GPUs             |
| **Software**   | SwRast (LLVMPipe)    | Last resort fallback                                |

---

## ⚠️ Requirements

- **Termux**: [Download from F-Droid](https://f-droid.org/en/packages/com.termux/) (Google Play version is outdated).
- **Termux:X11**: [Download latest APK](https://github.com/termux/termux-x11/actions) from GitHub Actions or nightly builds.
- **Termux:Widget**: (Optional) For Android home screen shortcuts.

### 🛡️ Android 12+ (Phantom Process Killer)

On Android 12 and newer, the system aggressively kills background processes (like your Linux session). DexLinux handles this automatically if your device is **rooted**.

For **non-rooted** devices, you **must** run these commands via ADB:

1.  **Enable Developer Options**: Go to `Settings > About Phone` and tap `Build Number` 7 times.
2.  **Enable USB Debugging**: In `Developer Options`, turn on `USB Debugging`.
3.  **Run from a PC (ADB)**:
    - Download **Android Platform Tools**: [Windows](https://dl.google.com/android/repository/platform-tools-latest-windows.zip) | [Mac](https://dl.google.com/android/repository/platform-tools-latest-darwin.zip) | [Linux](https://dl.google.com/android/repository/platform-tools-latest-linux.zip)
    - Extract the ZIP and run:
    ```bash
    adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
    adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
    adb shell settings put global settings_enable_monitor_phantom_procs false
    ```
4.  **No PC? (Wireless Debugging)**: Use an app like [LADB](https://play.google.com/store/apps/details?id=com.draco.ladb) or Termux's own `adb` package to run the commands locally via Wireless Debugging.

- **Storage**: 5GB - 15GB of free space recommended for a full experience.

---

## 🤝 Credits & Acknowledgements

- **Themes**: [Orchis](https://github.com/vinceliuice/Orchis-theme) by Vinceliuice.
- **Icons**: [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) by Papirus Development Team.
- **Core**: Built on the amazing work of the Termux and Termux-X11 communities.
- **Phantom Process Killer**: [ThamSkai](https://github.com/ThamSkai/Termux-Phantom-Process-Killer).

---

**Developed with ❤️ by LuigiFaria88**
