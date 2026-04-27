# Android-Linux-Desktop

**Android-Linux-Desktop** is a comprehensive script designed to transform your Android device into a fully functional Linux desktop environment. It automates the setup of **Termux**, **Proot-Distro**, and various desktop environments (GNOME, XFCE, KDE) with a user-friendly menu-driven interface.

## Features

- **One-Click Installation**: Simplifies the setup of Termux and Proot-Distro.
- **Multiple Desktop Environments**:
  - **GNOME**: A modern and feature-rich desktop environment.
  - **XFCE**: A lightweight and fast desktop environment.
  - **KDE (Plasma)**: A powerful and customizable desktop environment.
- **Easy Switching**: Easily switch between different desktop environments.
- **Automatic Configuration**: Automatically configures display settings and starts the desktop environment.
- **Convenience Scripts**: Includes shortcuts to launch desktop environments, install packages, update the system, and manage the environment.

## Installation

To install and run the script, simply execute the following command in your terminal (e.g., through an existing Termux session or a similar environment):

```bash
curl -sL https://raw.githubusercontent.com/luigifaria88/Android-Linux-Desktop/blob/main/DexLinux.sh | bash
```

The script will automatically:

1. Install necessary packages.
2. Install Proot-Distro.
3. Set up your chosen Linux distribution and desktop environment.
4. Provide you with a menu to manage your setup.

## Usage

After running the installation script, you will be presented with a menu. You can:

- **Install/Reinstall** a desktop environment (GNOME, XFCE, KDE).
- **Uninstall** the desktop environment.
- **Change/Switch** to a different desktop environment.
- **Manage Packages**: Install or update software within your Linux environment.
- **Launch** your desktop environment.
- **Exit** the script.

### Example: Installing GNOME

1. Run the installation command above.
2. Select the "Install/Reinstall GNOME" option from the menu.
3. Follow the prompts.
4. Once installed, select "Launch GNOME Desktop" to start your desktop session.

## Requirements

- An Android device capable of running Termux (or similar terminal emulator).
- Sufficient storage space for the desktop environment (GNOME requires the most space).
- Internet connection for downloading packages.

## Troubleshooting

- **Installation fails**: Ensure you have a stable internet connection and enough storage space.
- **Desktop won't start**: Make sure you have completed the installation and configuration steps correctly. You may need to restart Termux or the script.
- **Missing packages**: You can install additional software using the "Package Manager" option in the main menu.
