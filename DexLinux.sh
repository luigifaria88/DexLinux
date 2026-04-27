#!/data/data/com.termux/files/usr/bin/bash
#######################################################
#  🤖 MOBILE LINUX DESKTOP - DexLinux v1.0 🐧
#  
#  Features:
#  - Premium Fluent Theme & Papirus Icons
#  - Android Storage Integration (Symlinks)
#  - PRoot support (Ubuntu/Debian)
#  - GPU acceleration auto-setup (Turnip/Zink)
#  - One-click desktop launch
#  
#  Author: LuigiFaria88
#
#######################################################
# ============== CONFIGURATION ==============
TOTAL_STEPS=14
CURRENT_STEP=0
INSTALL_NETWORK=true
INSTALL_WINE=true
INSTALL_PROOT=false
PROOT_DISTRO="ubuntu"
HAS_ROOT=false

# Auto-detect terminal width for UI
TERM_COLS=$(tput cols 2>/dev/null || echo 45)
# Ensure a minimum width to prevent UI breakage
[[ -z "$TERM_COLS" || "$TERM_COLS" -lt 40 ]] && TERM_COLS=40
# Apply a slight margin
BOX_WIDTH=$((TERM_COLS - 2))
# Cap at 80 characters for ultra-wide screens to keep it readable
[[ "$BOX_WIDTH" -gt 80 ]] && BOX_WIDTH=80

# ============== COLORS (Fluent Palette) ==============
RED='\033[38;2;255;95;95m'
GREEN='\033[38;2;144;238;144m'
YELLOW='\033[38;2;255;218;121m'
BLUE='\033[38;2;112;161;255m'
PURPLE='\033[38;2;162;155;254m'
CYAN='\033[38;2;129;236;236m'
WHITE='\033[38;2;223;228;234m'
GRAY='\033[38;2;149;165;166m'
NC='\033[0m'
BOLD='\033[1m'

# ============== UI HELPER FUNCTIONS ==============
# Draw section header
draw_box() {
    local title="$1"
    echo -e "${CYAN}▶ ${WHITE}${BOLD}${title}${NC}"
}

# Draw separator
draw_bottom() {
    local box_width=${BOX_WIDTH:-45}
    echo -e "${GRAY}$(printf '─%.0s' $(seq 1 ${box_width}))${NC}"
}

# Draw indented content
draw_line() {
    local content="$1"
    echo -e "  ${content}"
}

print_status() {
    local icon="$1"
    local msg="$2"
    echo -e "  ${icon}  ${msg}"
}

# Update overall progress
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))
    
    local box_width=${BOX_WIDTH:-45}
    local bar_width=$(( box_width - 28 ))
    [[ $bar_width -lt 10 ]] && bar_width=10
    
    local filled=$(( PERCENT * bar_width / 100 ))
    local empty=$(( bar_width - filled ))
    
    local bar="${GREEN}"
    for ((i=0; i<filled; i++)); do bar+="━"; done
    bar+="${GRAY}"
    for ((i=0; i<empty; i++)); do bar+="─"; done
    bar+="${NC}"
    
    echo ""
    printf "  ${WHITE}📊 PROGRESS: ${BOLD}%3d%%${NC} [%b] ${GRAY}%2d/%2d${NC}\n" "$PERCENT" "$bar" "$CURRENT_STEP" "$TOTAL_STEPS"
    echo ""
}
# Spinner animation for running tasks
spinner() {
    local pid=$1
    local message=$2
    local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
    local spin_len=${#spin}
    local i=0
    
    # Hide cursor
    printf "\e[?25l"
    
    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % spin_len ))
        local char="${spin:$i:1}"
        
        # Clear line and print spinner
        printf "\r\e[2K  ${CYAN}${char}${NC}  ${WHITE}${message}${NC}"
        sleep 0.1
    done
    
    wait $pid
    local res=$?
    
    # Show cursor and clear the animation line
    printf "\e[?25h\r\e[2K"
    
    if [ $res -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} ${WHITE}${message}${NC}"
    else
        echo -e "  ${RED}✗${NC} ${WHITE}${message}${NC} ${RED}(failed)${NC}"
    fi
    
    return $res
}
# Install package with progress
install_pkg() {
    local pkg=$1
    local name=${2:-$pkg}
    
    (yes | pkg install $pkg -y > /dev/null 2>&1) &
    spinner $! "Installing ${name}..."
}
# ============== BANNER ==============
show_banner() {
    clear
    local title="DexLinux v1.0"
    local sub1="Mobile Linux Desktop"
    local sub2="Design by LuigiFaria88"
    
    local pad_title=$(( (BOX_WIDTH - ${#title}) / 2 ))
    [[ $pad_title -lt 0 ]] && pad_title=0
    local pad_sub1=$(( (BOX_WIDTH - ${#sub1}) / 2 ))
    [[ $pad_sub1 -lt 0 ]] && pad_sub1=0
    local pad_sub2=$(( (BOX_WIDTH - ${#sub2}) / 2 ))
    [[ $pad_sub2 -lt 0 ]] && pad_sub2=0
    
    echo ""
    echo -e "${CYAN}$(printf '━%.0s' $(seq 1 ${BOX_WIDTH}))${NC}"
    printf "%*s%b\n" "$pad_title" "" "${BOLD}${WHITE}${title}${NC}"
    printf "%*s%b\n" "$pad_sub1" "" "${CYAN}${sub1}${NC}"
    printf "%*s%b\n" "$pad_sub2" "" "${GRAY}${sub2}${NC}"
    echo -e "${CYAN}$(printf '━%.0s' $(seq 1 ${BOX_WIDTH}))${NC}"
    echo ""
}
# ============== DISTRO SELECTION ==============
select_distro() {
    echo ""
    draw_box "Subsystem Selection"
    draw_line "${WHITE}1)${NC} Ubuntu 24.04 ${GRAY}(Recommended)${NC}"
    draw_line "${WHITE}2)${NC} Debian ${GRAY}(Stable)${NC}"
    draw_line "${WHITE}3)${NC} Arch Linux ${GRAY}(Bleeding Edge)${NC}"
    draw_line "${WHITE}4)${NC} Kali Linux ${GRAY}(Security Tools)${NC}"
    draw_bottom
    echo ""
    read -p "  Select option [1-4]: " d_choice < /dev/tty
    case $d_choice in
        2) PROOT_DISTRO="debian" ;;
        3) PROOT_DISTRO="archlinux" ;;
        4) PROOT_DISTRO="kali" ;;
        *) PROOT_DISTRO="ubuntu" ;;
    esac
    echo ""
    read -p "  Enter a username for the Distro (default: dex): " PROOT_USER < /dev/tty
    [[ -z "$PROOT_USER" ]] && PROOT_USER="dex"
    
    print_status "✅" "Selected: ${WHITE}${BOLD}${PROOT_DISTRO}${NC} (User: ${PROOT_USER})"
    echo ""
}
# ============== SELECTION MENU ==============
show_menu() {
    draw_box "Installation Mode"
    draw_line "${CYAN}1)${NC} ${BOLD}Full Installation${NC} ${GRAY}(All tools + Distro)${NC}"
    draw_line "${CYAN}2)${NC} ${BOLD}Minimal Installation${NC} ${GRAY}(No Distro, No tools)${NC}"
    draw_line "${CYAN}3)${NC} ${BOLD}Custom Installation${NC} ${GRAY}(Choose manually)${NC}"
    draw_bottom
    echo ""
    read -p "  Select option [1-3]: " mode_choice < /dev/tty

    case $mode_choice in
        1)
            INSTALL_PROOT=true
            TOTAL_STEPS=15
            select_distro
            ;;
        2)
            INSTALL_NETWORK=false
            INSTALL_WINE=false
            TOTAL_STEPS=12
            ;;
        3)
            echo ""
            read -p "  Install Network Tools? (y/n): " h_choice < /dev/tty
            [[ "$h_choice" != "y" ]] && INSTALL_NETWORK=false
            read -p "  Install Wine (Windows Apps)? (y/n): " w_choice < /dev/tty
            [[ "$w_choice" != "y" ]] && INSTALL_WINE=false
            read -p "  Enable PRoot (Linux Subsystems)? (y/n): " p_choice < /dev/tty
            if [[ "$p_choice" == "y" ]]; then
                INSTALL_PROOT=true
                select_distro
            fi
            
            # Recalculate steps
            TOTAL_STEPS=12
            [[ "$INSTALL_NETWORK" == "true" ]] && TOTAL_STEPS=$((TOTAL_STEPS + 1))
            [[ "$INSTALL_WINE" == "true" ]] && TOTAL_STEPS=$((TOTAL_STEPS + 1))
            [[ "$INSTALL_PROOT" == "true" ]] && TOTAL_STEPS=$((TOTAL_STEPS + 1))
            ;;
        *)
            INSTALL_PROOT=true
            TOTAL_STEPS=15
            ;;
    esac
}
# ============== ROOT DETECTION ==============
check_root() {
    if [ -x "$(command -v su)" ]; then
        # Try to run id command via su
        if su -c "id" > /dev/null 2>&1; then
            HAS_ROOT=true
        fi
    fi
}
# ============== ENVIRONMENT CHECKS ==============
check_environment() {
    draw_box "System Pre-flight"
    
    # Check Android Version
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null | tr -d '\r')
    ANDROID_MAJOR="${ANDROID_VERSION%%.*}"
    [[ -z "$ANDROID_MAJOR" ]] && ANDROID_MAJOR=0

    if [ "$ANDROID_MAJOR" -ge 12 ]; then
        print_status "⚠️" "Android 12+ detected."
        draw_line "    ${GRAY}Disable Phantom Process Killer:${NC}"
        draw_line "    ${CYAN}device_config put activity_manager ${NC}\\"
        draw_line "    ${CYAN}max_phantom_processes 2147483647${NC}"
    else
        print_status "✅" "Android ${ANDROID_VERSION:-Unknown} compatibility: OK"
    fi
    
    # Check Architecture
    if [ "$CPU_ABI" != "arm64-v8a" ]; then
        print_status "⚠️" "Warning: Non-arm64 architecture might have performance issues."
    fi
    
    draw_bottom
    echo ""
    sleep 2
}

# ============== DEVICE DETECTION ==============
detect_device() {
    draw_box "Hardware Information"
    
    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null | tr -d '\r' || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null | tr -d '\r' || echo "Unknown")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null | tr -d '\r' || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null | tr -d '\r' || echo "arm64-v8a")
    
    GPU_VENDOR=$(getprop ro.hardware.egl 2>/dev/null | tr -d '\r' || echo "")
    
    print_status "📱" "Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    print_status "🤖" "Android: ${WHITE}${ANDROID_VERSION}${NC}"
    
    check_root
    if [ "$HAS_ROOT" == "true" ]; then
        print_status "🔓" "Root: ${GREEN}Available${NC}"
    else
        print_status "🔒" "Root: ${RED}Not Available${NC}"
    fi
    
    if [[ "$GPU_VENDOR" == *"adreno"* ]] || [[ "$DEVICE_BRAND" == *"samsung"* ]] || [[ "$DEVICE_BRAND" == *"Samsung"* ]] || [[ "$DEVICE_BRAND" == *"oneplus"* ]] || [[ "$DEVICE_BRAND" == *"xiaomi"* ]]; then
        GPU_DRIVER="freedreno"
        print_status "🎮" "GPU: ${WHITE}Adreno (Native Acceleration)${NC}"
    else
        GPU_DRIVER="swrast"
        print_status "🎮" "GPU: ${YELLOW}Software Rendering (Fallback)${NC}"
    fi
    draw_bottom
    sleep 1
}
# ============== STEP 1: UPDATE SYSTEM ==============
step_update() {
    update_progress
    draw_box "Updating System"
    
    (yes | pkg update -y > /dev/null 2>&1) &
    spinner $! "Updating package lists"
    
    (yes | pkg upgrade -y > /dev/null 2>&1) &
    spinner $! "Upgrading installed packages"
    draw_bottom
}
# ============== STEP 2: INSTALL REPOSITORIES & TOOLS ==============
step_repos() {
    update_progress
    draw_box "Core Repositories & Tools"
    
    install_pkg "x11-repo" "X11 Repository"
    install_pkg "tur-repo" "TUR Repository"
    install_pkg "wget" "Wget Downloader"
    install_pkg "curl" "cURL"
    install_pkg "git" "Git"
    install_pkg "sassc" "Sass Compiler"
    install_pkg "tar" "Tar Utility"
    install_pkg "file" "File Utility"
    draw_bottom
}
# ============== STEP 3: INSTALL TERMUX-X11 ==============
step_x11() {
    update_progress
    draw_box "Termux-X11 Display Server"
    
    install_pkg "termux-x11-nightly" "Display Server"
    install_pkg "xorg-xrandr" "XRandR Utility"
    draw_bottom
}
# ============== STEP 4: INSTALL DESKTOP ==============
step_desktop() {
    update_progress
    draw_box "XFCE4 Desktop Environment"
    
    install_pkg "xfce4" "XFCE4 Desktop"
    install_pkg "xfce4-terminal" "XFCE4 Terminal"
    install_pkg "thunar" "Thunar File Manager"
    install_pkg "mousepad" "Mousepad Editor"
    install_pkg "gtk2-engines-murrine" "Murrine Engine"
    install_pkg "gdk-pixbuf" "GDK Pixbuf"
    draw_bottom
}
# ============== STEP 5: INSTALL GPU DRIVERS ==============
step_gpu() {
    update_progress
    draw_box "GPU Acceleration (Turnip/Zink)"
    
    install_pkg "mesa-zink" "Mesa Zink (OpenGL)"
    
    if [ "$GPU_DRIVER" == "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Driver"
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan"
    fi
    
    # Install Vulkan Loader with fallback
    (pkg install vulkan-loader -y > /dev/null 2>&1) &
    spinner $! "Vulkan Loader"
    
    draw_line "${GREEN}✓${NC} GPU acceleration configured!"
    draw_bottom
}
# ============== STEP 6: INSTALL AUDIO ==============
step_audio() {
    update_progress
    draw_box "Audio Support"
    install_pkg "pulseaudio" "PulseAudio Server"
    draw_bottom
}
# ============== STEP 7: ANDROID INTEGRATION ==============
step_storage() {
    update_progress
    draw_box "Android Storage Integration"
    
    draw_line "${YELLOW}⚠${NC} Please allow storage permission!"
    termux-setup-storage
    sleep 2
    
    mkdir -p ~/Desktop
    ln -sf /sdcard/Download ~/Desktop/Android_Downloads
    ln -sf /sdcard/DCIM ~/Desktop/Android_Photos
    ln -sf /sdcard/Documents ~/Desktop/Android_Docs
    
    draw_line "${GREEN}✓${NC} Symlinks created on Desktop"
    draw_bottom
}
# ============== STEP 9: THEMES & ICONS ==============
step_themes() {
    update_progress
    draw_box "Premium Themes & Icons"
    
    install_pkg "papirus-icon-theme" "Papirus Icons"
    mkdir -p ~/.themes ~/.icons
    
    draw_line "${YELLOW}⏳${NC} Cloning Orchis Theme..."
    T_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/orchis-theme"
    rm -rf "$T_DIR"
    mkdir -p "$T_DIR"
    
    if git clone --depth 1 https://github.com/vinceliuice/Orchis-theme.git "$T_DIR" > /dev/null 2>&1; then
        cd "$T_DIR"
        find . -type f -name "*.sh" -exec termux-fix-shebang {} \; 2>/dev/null
        bash install.sh -d ~/.themes -c dark > /dev/null 2>&1
        draw_line "${GREEN}✓${NC} Orchis Theme installed"
        cd - > /dev/null
    else
        draw_line "${RED}✗${NC} Failed to clone theme repository"
    fi
    rm -rf "$T_DIR"
    
    draw_line "${YELLOW}⏳${NC} Applying XFCE configuration..."
    CONF_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
    mkdir -p "$CONF_DIR"
    
    cat > "$CONF_DIR/xsettings.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Orchis-Dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="CursorThemeName" type="string" value="Adwaita"/>
  </property>
</channel>
EOF

    cat > "$CONF_DIR/xfwm4.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Orchis-Dark"/>
  </property>
</channel>
EOF

    cat > "$CONF_DIR/xfce4-desktop.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="desktop-icons" type="empty">
    <property name="file-icons" type="empty">
      <property name="show-filesystem" type="bool" value="false"/>
    </property>
  </property>
</channel>
EOF
    draw_bottom
}
# ============== STEP 10: INSTALL BROWSERS & APPS ==============
step_apps() {
    update_progress
    draw_box "Core Applications"
    install_pkg "firefox" "Firefox Browser"
    install_pkg "git" "Git VSC"
    draw_bottom
}
# ============== STEP 8: INSTALL NETWORK TOOLS ==============
step_network_tools() {
    update_progress
    draw_box "Network Analysis Tools"
    
    install_pkg "nmap" "Nmap Scanner"
    install_pkg "netcat-openbsd" "Netcat"
    install_pkg "whois" "Whois"
    install_pkg "dnsutils" "DNS Utils"
    install_pkg "tracepath" "Tracepath"
    draw_bottom
}
# ============== STEP 12: INSTALL PROOT (OPTIONAL) ==============
step_proot() {
    update_progress
    draw_box "PRoot Subsystem (${PROOT_DISTRO})"
    
    install_pkg "proot-distro" "PRoot Manager"
    
    (proot-distro install ${PROOT_DISTRO} > /dev/null 2>&1) &
    spinner $! "Installing ${PROOT_DISTRO}"
    
    if ! proot-distro login ${PROOT_DISTRO} -- bash -c "grep -q 'DEXLINUX_CONFIG' /etc/profile" > /dev/null 2>&1; then
        (proot-distro login ${PROOT_DISTRO} -- bash -c "
            apt update && apt install -y sudo wget curl git mesa-utils > /dev/null 2>&1
            if ! id -u ${PROOT_USER} >/dev/null 2>&1; then
                useradd -m -s /bin/bash ${PROOT_USER}
                echo '${PROOT_USER} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${PROOT_USER}
                chmod 0440 /etc/sudoers.d/${PROOT_USER}
            fi
            cat >> /etc/profile << 'EOF'
# DEXLINUX_CONFIG_START
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
# DEXLINUX_CONFIG_END
EOF
        " > /dev/null 2>&1) &
        spinner $! "Bootstrapping environment"
    fi

    D_NAME=$(echo "$PROOT_DISTRO" | sed 's/./\U&/')
    cat > ~/Desktop/${D_NAME}.desktop << EOF
[Desktop Entry]
Name=${D_NAME} Shell
Comment=Open ${D_NAME} environment with GPU Support
Exec=xfce4-terminal -e "bash -c 'export DISPLAY=:0; source ~/.config/dexlinux-gpu.sh; proot-distro login ${PROOT_DISTRO} --user ${PROOT_USER}'"
Icon=utilities-terminal
Type=Application
Categories=System;
EOF
    chmod +x ~/Desktop/${D_NAME}.desktop
    draw_bottom
}
# ============== STEP 13: FIRST RUN SCRIPT ==============
step_firstrun() {
    update_progress
    echo ""
    
    mkdir -p ~/.config/autostart
    cat > ~/.config/autostart/dexlinux-setup.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=DexLinux Setup
Exec=xfce4-terminal -e "bash ~/dexlinux-firstrun.sh"
OnlyShowIn=XFCE;
RunHook=0
EOF

    cat > ~/dexlinux-firstrun.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  💿 Welcome to DexLinux v1.0 Setup!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Let's finish your configuration:"
echo ""
echo "Set a password for your Termux background session (optional):"
passwd
echo ""
echo "Optimizing display scaling..."
xfconf-query -c xsettings -p /Gdk/WindowScalingFactor -s 1 --create 2>/dev/null
echo ""
echo "✅ All set! Enjoy your Mobile Linux Desktop."
echo "Press Enter to close this window."
read
rm ~/.config/autostart/dexlinux-setup.desktop
rm ~/dexlinux-firstrun.sh
EOF
    chmod +x ~/dexlinux-firstrun.sh
}
# ============== STEP 10: INSTALL METASPLOIT ==============
# ============== STEP 11: INSTALL WINE (WINDOWS APPS) ==============
step_wine() {
    update_progress
    draw_box "Wine (Windows Support)"
    
    (pkg remove wine-stable -y > /dev/null 2>&1) &
    spinner $! "Cleaning old versions"
    
    install_pkg "hangover-wine" "Wine (Hangover)"
    install_pkg "hangover-wowbox64" "Box64 Wrapper"
    
    ln -sf /data/data/com.termux/files/usr/opt/hangover-wine/bin/wine /data/data/com.termux/files/usr/bin/wine
    ln -sf /data/data/com.termux/files/usr/opt/hangover-wine/bin/winecfg /data/data/com.termux/files/usr/bin/winecfg
    
    wine reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f > /dev/null 2>&1
    draw_line "${GREEN}✓${NC} UI Optimized"
    draw_bottom
}
# ============== STEP 12: CREATE LAUNCHER SCRIPTS ==============
step_launchers() {
    update_progress
    draw_box "Finalizing Launchers"
    
    mkdir -p ~/.config
    cat > ~/.config/dexlinux-gpu.sh << 'GPUEOF'
# Mobile DexLinux - GPU Acceleration Config
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS}
GPUEOF
    draw_line "${GREEN}✓${NC} GPU config created"
    
    if ! grep -q "dexlinux-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/dexlinux-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi
    
    # Customize Termux Prompt to hide u0_aXXX
    if ! grep -q "PS1=" ~/.bashrc 2>/dev/null; then
        echo "export PS1=\"\\[\\e[32m\\]${PROOT_USER:-dex}\\[\\e[m\\]@\\[\\e[34m\\]dexlinux\\[\\e[m\\]:\\[\\e[36m\\]\\w\\[\\e[m\\]\\$ \"" >> ~/.bashrc
    fi
    
    # Main Launcher
    cat > ~/start-dexlinux.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting DexLinux Desktop..."
export USER="user"
export LOGNAME="user"
export XDG_RUNTIME_DIR=${TMPDIR:-/data/data/com.termux/files/usr/tmp}
source ~/.config/dexlinux-gpu.sh 2>/dev/null
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1
rm -rf $XDG_RUNTIME_DIR/.X11-unix/X0 2>/dev/null
am start -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1
termux-x11 :0 -ac > ~/x11.log 2>&1 &
MAX_TRIES=60
COUNT=0
while [ ! -e $XDG_RUNTIME_DIR/.X11-unix/X0 ] && [ $COUNT -lt $MAX_TRIES ]; do
    sleep 0.5
    COUNT=$((COUNT + 1))
done
export DISPLAY=:0
exec startxfce4
LAUNCHEREOF
    chmod +x ~/start-dexlinux.sh
    draw_line "${GREEN}✓${NC} Created ~/start-dexlinux.sh"
    
    # Rest of tool scripts
    cat > ~/dex-res.sh << 'RESOEOF'
#!/data/data/com.termux/files/usr/bin/bash
OUTPUT=$(xrandr | grep " connected" | cut -d' ' -f1 | head -n1)
if [ -z "$OUTPUT" ]; then
    echo -e "\033[31m[!] Error: X11 not detected.\033[0m"
    exit 1
fi
clear
echo "╔═══════════════════════════════════════════╗"
echo "║       📱  DexLinux - Resolution           ║"
echo "╠═══════════════════════════════════════════╣"
echo "║  1) Auto (Native)                         ║"
echo "║  2) Performance (720p)                    ║"
echo "║  3) Balanced (900p)                       ║"
echo "║  4) Full HD (1080p)                       ║"
echo "║  5) Zoom + (Large Text)                   ║"
echo "║  6) Zoom - (More Space)                   ║"
echo "╚═══════════════════════════════════════════╝"
read -p "  Option: " r_opt
case $r_opt in
    1) xrandr --output $OUTPUT --auto ;;
    2) xrandr --output $OUTPUT --scale 0.7x0.7 ;;
    3) xrandr --output $OUTPUT --scale 0.85x0.85 ;;
    4) xrandr --output $OUTPUT --scale 1x1 ;;
    5) xrandr --output $OUTPUT --scale 0.8x0.8 ;;
    6) xrandr --output $OUTPUT --scale 1.25x1.25 ;;
esac
RESOEOF
    chmod +x ~/dex-res.sh

    cat > ~/dex-tools.sh << 'TOOLSEOF'
#!/data/data/com.termux/files/usr/bin/bash
while true; do
    clear
    echo "╔═══════════════════════════════════════════╗"
    echo "║     🔧       DexLinux - Quick Tools       ║"
    echo "╠═══════════════════════════════════════════╣"
    echo "║  1) 🌐 Nmap - Network Scan                ║"
    echo "║  2) 💀 Metasploit Console                 ║"
    echo "║  3) 🖥️  Start Desktop                     ║"
    echo "║  4) 📏 Change Resolution (xrandr)         ║"
    echo "║  5) 🔍 Check GPU Status                   ║"
    echo "║  0) ❌ Exit                               ║"
    echo "╚═══════════════════════════════════════════╝"
    read -p "  Select option: " choice
    case $choice in
        1) read -p "Target: " t; nmap -sV $t; read -p "Enter...";;
        2) msfconsole;;
        3) bash ~/start-dexlinux.sh;;
        4) bash ~/dex-res.sh;;
        5) glxinfo | grep "renderer"; read -p "Enter...";;
        0) exit 0;;
    esac
done
TOOLSEOF
    chmod +x ~/dex-tools.sh

    cat > ~/stop-dexlinux.sh << 'STOPEOF'
#!/data/data/com.termux/files/usr/bin/bash
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
STOPEOF
    chmod +x ~/stop-dexlinux.sh
    draw_bottom
}
# ============== STEP 13: CREATE DESKTOP SHORTCUTS ==============
step_shortcuts() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Desktop Shortcuts...${NC}"
    echo ""
    
    mkdir -p ~/Desktop
    
    # Firefox
    cat > ~/Desktop/Firefox.desktop << 'EOF'
[Desktop Entry]
Name=Firefox
Comment=Web Browser
Exec=firefox
Icon=firefox
Type=Application
Categories=Network;WebBrowser;
EOF
    
    # Display Settings
    cat > ~/Desktop/Resolution.desktop << 'EOF'
[Desktop Entry]
Name=Display Settings
Comment=Change Screen Resolution
Exec=xfce4-terminal -e "bash /data/data/com.termux/files/home/dex-res.sh"
Icon=preferences-desktop-display
Type=Application
Categories=Settings;
EOF

    # Quick Tools
    cat > ~/Desktop/DexTools.desktop << 'EOF'
[Desktop Entry]
Name=DexTools
Comment=Network & System Tools
Exec=xfce4-terminal -e "bash /data/data/com.termux/files/home/dex-tools.sh"
Icon=utilities-terminal
Type=Application
Categories=System;
EOF

    # Shutdown
    cat > ~/Desktop/Shutdown.desktop << 'EOF'
[Desktop Entry]
Name=Shutdown DexLinux
Comment=Stop Desktop Session
Exec=bash /data/data/com.termux/files/home/stop-dexlinux.sh
Icon=system-shutdown
Type=Application
Categories=System;
EOF
    
    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts created"
}
# ============== COMPLETION ==============
show_completion() {
    echo ""
    draw_box "Installation Complete"
    print_status "🎉" "DexLinux is now ready!"
    print_status "🚀" "Start with: ${GREEN}bash ~/start-dexlinux.sh${NC}"
    print_status "🛑" "Stop with: ${RED}bash ~/stop-dexlinux.sh${NC}"
    draw_bottom
    echo ""
    
    echo -e "${CYAN}📦 Core Components:${NC}"
    echo -e "   • XFCE4 Desktop ${GRAY}(Premium Theme)${NC}"
    echo -e "   • GPU Acceleration ${GRAY}(Zink/Turnip)${NC}"
    echo -e "   • PulseAudio ${GRAY}(Low Latency)${NC}"
    echo ""
    print_status "⚡" "${BOLD}Tip:${NC} Open Termux:X11 app BEFORE running the start script."
    echo ""
}
# ============== MAIN INSTALLATION ==============
main() {
    show_banner
    show_menu
    
    echo ""
    print_status "ℹ️ " "Starting DexLinux v1.1 Deployment"
    echo -e "${GRAY}  Estimated time: 10-20 minutes.${NC}"
    echo ""
    read -p "  Press Enter to begin..." < /dev/tty
    
    # Run all steps
    detect_device
    check_environment
    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_storage
    step_themes
    step_apps
    
    if [ "$INSTALL_NETWORK" == "true" ]; then
        step_network_tools
    fi
    
    [[ "$INSTALL_PROOT" == "true" ]] && step_proot
    [[ "$INSTALL_WINE" == "true" ]] && step_wine
    
    step_launchers
    step_shortcuts
    step_firstrun
    
    show_completion
}
# ============== RUN ==============
main
