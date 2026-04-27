# DexLinux - Mobile Linux Desktop

**DexLinux** is a comprehensive script designed to transform your Android device into a fully functional Linux desktop environment using Termux. It automates the setup of Termux-X11, XFCE4 desktop, GPU acceleration, and optionally PRoot subsystems.

## Features

- **Automated Setup**: One-script installation for a complete desktop environment.
- **XFCE4 Desktop**: Lightweight and fast, pre-configured with the premium Fluent theme and Papirus icons.
- **GPU Acceleration**: Auto-setup for Turnip/Zink drivers to provide hardware acceleration.
- **Audio Support**: Integrated PulseAudio for sound.
- **Android Integration**: Automatic symlinks to your Android storage (Downloads, Photos, Docs).
- **PRoot Subsystems**: Optional installation of Ubuntu 24.04, Debian, Arch Linux, or Kali Linux.
- **Windows Apps Support**: Optional Wine (Hangover/Box64) integration.
- **Utility Scripts**: Includes shortcuts to manage resolution, network tools, and desktop sessions.

## Installation

To install and run the script, execute the following command in Termux:

```bash
curl -sL https://raw.githubusercontent.com/luigifaria88/Android-Linux-Desktop/main/DexLinux.sh | bash
```

The script will present you with an installation menu:

1. **Full Installation**: Installs all tools, XFCE desktop, and prompts for a PRoot subsystem.
2. **Minimal Installation**: Installs the core XFCE desktop without additional network tools or Wine.
3. **Custom Installation**: Allows you to choose exactly which components to install.

## Usage

After installation, you can use the generated shortcuts on your desktop or the following commands in Termux:

- **Start Desktop**: `bash ~/start-dexlinux.sh`
- **Stop Desktop**: `bash ~/stop-dexlinux.sh`
- **Change Resolution**: `bash ~/dex-res.sh`
- **Quick Tools**: `bash ~/dex-tools.sh` (Access network tools and system status)

### Launching the Desktop

1. Open the **Termux:X11** app.
2. Go back to the **Termux** terminal app.
3. Run `bash ~/start-dexlinux.sh`.
4. Switch to the **Termux:X11** app to see your desktop.

## Requirements

- Android device with **Termux** installed.
- Android 12+ users might need to disable the Phantom Process Killer (instructions provided during script pre-flight check).
- Sufficient storage space (depends on the chosen PRoot subsystem and tools).
- Internet connection for downloading packages.

## Troubleshooting

- **Desktop won't start**: Ensure the Termux:X11 app is running before executing the start script. If it still fails, check the `~/x11.log` file for errors.
- **No hardware acceleration**: Depends on device compatibility (Adreno GPUs usually have native Turnip support; others might fallback to software rendering).
