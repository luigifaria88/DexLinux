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
INSTALL_EXTRA_APPS="1"

INSTALL_PROOT=false
PROOT_DISTRO="ubuntu"
HAS_ROOT=false
SYS_LOCALE="en_US.UTF-8"
SYS_KBD="us"

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
    
    (yes | pkg install $pkg -y) > /dev/null 2>&1 &
    spinner $! "Installing ${name}..."
}
# ============== BANNER ==============
show_banner() {
    clear
    TERM_COLS=$(tput cols 2>/dev/null || echo 45)
    [[ "$TERM_COLS" -lt 40 ]] && TERM_COLS=40
    BOX_WIDTH=$((TERM_COLS - 4))
    [[ "$BOX_WIDTH" -gt 76 ]] && BOX_WIDTH=76

    local title="DexLinux v1.0"
    local sub1="Mobile Linux Desktop"
    local sub2="Design by LuigiFaria88"
    
    print_centered() {
        local text="$1"
        local color="$2"
        local text_len=${#text}
        local padding=$(( (BOX_WIDTH - text_len) / 2 ))
        local rem=$(( (BOX_WIDTH - text_len) % 2 ))
        printf "${CYAN}┃${NC}%*s${color}%s${NC}%*s${CYAN}┃${NC}\n" "$padding" "" "$text" "$((padding + rem))" ""
    }

    echo -e "${CYAN}┏$(printf '━%.0s' $(seq 1 $BOX_WIDTH))┓${NC}"
    print_centered "$title" "${BOLD}${WHITE}"
    print_centered "$sub1" "${CYAN}"
    print_centered "$sub2" "${GRAY}"
    echo -e "${CYAN}┗$(printf '━%.0s' $(seq 1 $BOX_WIDTH))┛${NC}"
    echo ""
}

# ============== DISTRO SELECTION ==============
select_distro() {
    echo ""
    draw_box "Subsystem Selection"
    draw_line "${WHITE}1)${NC} Ubuntu ${GRAY}(Recommended)${NC}"
    draw_line "${WHITE}2)${NC} Debian ${GRAY}(Stable)${NC}"
    draw_line "${WHITE}3)${NC} Arch Linux ${GRAY}(Bleeding Edge)${NC}"
    draw_line "${WHITE}4)${NC} Fedora ${GRAY}(Workstation)${NC}"
    draw_line "${WHITE}5)${NC} Deepin ${GRAY}(Beautiful UI)${NC}"
    draw_bottom
    echo ""
    read -p "  Select option [1-5]: " d_choice < /dev/tty
    case $d_choice in
        2) PROOT_DISTRO="debian" ;;
        3) PROOT_DISTRO="archlinux" ;;
        4) PROOT_DISTRO="fedora" ;;
        5) PROOT_DISTRO="deepin" ;;
        *) PROOT_DISTRO="ubuntu" ;;
    esac
    echo ""
    read -p "  Enter a username for the Distro (default: dex): " PROOT_USER < /dev/tty
    [[ -z "$PROOT_USER" ]] && PROOT_USER="dex"
    
    print_status "✅" "Selected: ${WHITE}${BOLD}${PROOT_DISTRO}${NC} (User: ${PROOT_USER})"
    echo ""
}
select_extra_apps() {
    local apps=("Firefox" "Chromium" "VS Code" "GIMP" "VLC" "LibreOffice" "Inkscape" "btop" "Wine + Box64")
    local selected=(false false false false false false false false false)
    
    # Pre-select defaults (Firefox)
    selected[0]=true

    while true; do
        show_banner
        draw_box "App Selection (Interactive)"
        draw_line "${GRAY}Toggle numbers, use [A]ll, [N]one, or [Enter] to finish${NC}"
        echo ""
        
        for i in "${!apps[@]}"; do
            if [ "${selected[$i]}" = true ]; then
                echo -e "  ${GREEN}●${NC}  ${WHITE}$((i+1)))${NC} ${BOLD}${apps[$i]}${NC} ${GREEN}✔${NC}"
            else
                echo -e "  ${GRAY}○${NC}  ${WHITE}$((i+1)))${NC} ${apps[$i]}"
            fi
        done
        
        echo ""
        draw_line "${CYAN}A)${NC} Select All"
        draw_line "${CYAN}N)${NC} Clear Selection"
        draw_line "${GREEN}Enter)${NC} ${BOLD}Confirm & Continue${NC}"
        draw_bottom
        echo ""
        
        read -p "  Choice: " choice < /dev/tty
        
        case $choice in
            [1-9]) 
                idx=$((choice-1))
                if [ "${selected[$idx]}" = true ]; then selected[$idx]=false; else selected[$idx]=true; fi
                ;;
            [Aa]) for i in "${!selected[@]}"; do selected[$i]=true; done ;;
            [Nn]) for i in "${!selected[@]}"; do selected[$i]=false; done ;;
            "") break ;;
        esac
    done

    # Export selection
    INSTALL_EXTRA_APPS=""
    for i in "${!selected[@]}"; do
        if [ "${selected[$i]}" = true ]; then
            INSTALL_EXTRA_APPS+="$((i+1)) "
        fi
    done
    
    [[ -z "$INSTALL_EXTRA_APPS" ]] && INSTALL_EXTRA_APPS="0"
    echo ""
}

select_language() {
    echo ""
    draw_box "Language & Keyboard"
    draw_line "${WHITE}1)${NC} English ${GRAY}(en_US)${NC}"
    draw_line "${WHITE}2)${NC} Portuguese ${GRAY}(pt_PT)${NC}"
    draw_line "${WHITE}3)${NC} Portuguese (BR) ${GRAY}(pt_BR)${NC}"
    draw_line "${WHITE}4)${NC} Spanish ${GRAY}(es_ES)${NC}"
    draw_line "${WHITE}5)${NC} French ${GRAY}(fr_FR)${NC}"
    draw_line "${WHITE}6)${NC} German ${GRAY}(de_DE)${NC}"
    draw_bottom
    echo ""
    read -p "  Select option [1-6]: " l_choice < /dev/tty
    case $l_choice in
        2) 
            SYS_LOCALE="pt_PT.UTF-8"
            SYS_KBD="pt"
            ;;
        3) 
            SYS_LOCALE="pt_BR.UTF-8"
            SYS_KBD="br"
            ;;
        4) 
            SYS_LOCALE="es_ES.UTF-8"
            SYS_KBD="es"
            ;;
        5) 
            SYS_LOCALE="fr_FR.UTF-8"
            SYS_KBD="fr"
            ;;
        6) 
            SYS_LOCALE="de_DE.UTF-8"
            SYS_KBD="de"
            ;;
        *) 
            SYS_LOCALE="en_US.UTF-8"
            SYS_KBD="us"
            ;;
    esac
    echo ""
    print_status "✅" "Language: ${WHITE}${BOLD}${SYS_LOCALE}${NC} | Keyboard: ${WHITE}${BOLD}${SYS_KBD}${NC}"
    echo ""
}

# ============== MAINTENANCE MENU ==============
show_maintenance_menu() {
    while true; do
        show_banner
        draw_box "Maintenance & System Tools"
        draw_line "${PURPLE}1)${NC} Remove a Distribution ${GRAY}(Arch, Fedora, etc)${NC}"
        draw_line "${PURPLE}2)${NC} Clean Package Cache ${GRAY}(Free up space)${NC}"
        draw_line "${PURPLE}3)${NC} Fix XFCE Permissions ${GRAY}(Repair start-up)${NC}"
        draw_line "${PURPLE}4)${NC} Reset Desktop Resolution ${GRAY}(Safe mode)${NC}"
        draw_line "${CYAN}B)${NC} Back to Main Menu"
        draw_bottom
        echo ""
        read -p "  Select option: " m_choice < /dev/tty
        
        case $m_choice in
            1)
                echo ""
                draw_box "Distro Removal"
                if command -v proot-distro > /dev/null; then
                    proot-distro list
                else
                    print_status "⚠️" "proot-distro is not installed yet."
                fi
                echo ""
                read -p "  Enter distro name to remove (or leave empty to cancel): " d_remove < /dev/tty
                if [[ -n "$d_remove" ]]; then
                    spinner_pid=$( (proot-distro remove "$d_remove") > /dev/null 2>&1 & echo $! )
                    spinner $spinner_pid "Removing $d_remove..."
                    rm -f ~/Desktop/"$(echo $d_remove | sed 's/./\U&/')".desktop 2>/dev/null
                fi
                ;;
            2)
                (pkg clean && apt autoremove -y) > /dev/null 2>&1 &
                spinner $! "Cleaning system cache..."
                ;;
            3)
                chmod +x ~/start-dexlinux.sh ~/.shortcuts/* 2>/dev/null
                print_status "✅" "Permissions repaired."
                sleep 1
                ;;
            4)
                rm -f ~/.config/dexlinux-res.sh 2>/dev/null
                print_status "✅" "Resolution reset to default."
                sleep 1
                ;;
            [Bb]) return ;;
        esac
    done
}

# ============== SELECTION MENU ==============
show_menu() {
    draw_box "Installation Mode"
    draw_line "${CYAN}1)${NC} ${BOLD}Full Installation${NC} ${GRAY}(All Apps + Distro)${NC}"
    draw_line "${CYAN}2)${NC} ${BOLD}Minimal Installation${NC} ${GRAY}(Core Desktop Only)${NC}"
    draw_line "${CYAN}3)${NC} ${BOLD}Custom Installation${NC} ${GRAY}(Choose manually)${NC}"
    draw_line "${PURPLE}M)${NC} ${BOLD}Maintenance Menu${NC} ${GRAY}(Remove distros, cleanup)${NC}"
    draw_bottom
    echo ""
    read -p "  Select option [1-3, M]: " mode_choice < /dev/tty

    case $mode_choice in
        [Mm])
            show_maintenance_menu
            exit 0
            ;;
        1)
            INSTALL_PROOT=true
            TOTAL_STEPS=14
            select_distro
            ;;
        2)
            INSTALL_EXTRA_APPS="0"
            TOTAL_STEPS=12
            ;;
        3)
            echo ""
            select_extra_apps
            read -p "  Enable PRoot (Linux Subsystems)? (y/n): " p_choice < /dev/tty
            if [[ "$p_choice" == "y" ]]; then
                INSTALL_PROOT=true
                select_distro
            fi
            
            # Recalculate steps
            TOTAL_STEPS=12
            [[ "$INSTALL_EXTRA_APPS" != *"0"* ]] && [[ -n "$INSTALL_EXTRA_APPS" ]] && TOTAL_STEPS=$((TOTAL_STEPS + 1))
            [[ "$INSTALL_PROOT" == "true" ]] && TOTAL_STEPS=$((TOTAL_STEPS + 1))
            ;;
        *)
            INSTALL_PROOT=true
            TOTAL_STEPS=14
            ;;
    esac
    
    select_language
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
    
    GPU_VENDOR_L=$(echo "$GPU_VENDOR" | tr '[:upper:]' '[:lower:]')
    DEVICE_BRAND_L=$(echo "$DEVICE_BRAND" | tr '[:upper:]' '[:lower:]')

    if [[ "$GPU_VENDOR_L" == *"adreno"* ]]; then
        GPU_DRIVER="freedreno"
        print_status "🎮" "GPU: ${WHITE}Adreno (Native Acceleration)${NC}"
    elif [[ "$GPU_VENDOR_L" == *"mali"* ]] || [[ "$GPU_VENDOR_L" == *"arm"* ]] || [[ "$DEVICE_BRAND_L" == *"huawei"* ]] || [[ "$DEVICE_BRAND_L" == *"honor"* ]]; then
        GPU_DRIVER="mali"
        print_status "🎮" "GPU: ${WHITE}Mali (Hardware Accelerated)${NC}"
    elif [[ "$GPU_VENDOR_L" == *"powervr"* ]] || [[ "$GPU_VENDOR_L" == *"pvr"* ]] || [[ "$GPU_VENDOR_L" == *"rogue"* ]]; then
        GPU_DRIVER="mali" # Use Zink path
        print_status "🎮" "GPU: ${WHITE}PowerVR (Hardware Accelerated)${NC}"
    elif [[ "$DEVICE_BRAND_L" =~ ^(samsung|oneplus|xiaomi|google|realme|oppo|vivo|motorola|nokia|sony|asus)$ ]]; then
        GPU_DRIVER="freedreno"
        print_status "🎮" "GPU: ${WHITE}${DEVICE_BRAND} (Assuming Adreno)${NC}"
    elif [[ -n "$GPU_VENDOR" ]] && [[ "$GPU_VENDOR_L" != *"swrast"* ]] && [[ "$GPU_VENDOR_L" != *"llvmpipe"* ]]; then
        GPU_DRIVER="mali" # Use Zink path
        print_status "🎮" "GPU: ${WHITE}${GPU_VENDOR} (Hardware Accelerated)${NC}"
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
    
    (yes | pkg update -y) > /dev/null 2>&1 &
    spinner $! "Updating package lists"
    
    (yes | pkg upgrade -y) > /dev/null 2>&1 &
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
    install_pkg "gnupg" "GnuPG (Keys)"
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
    
    install_pkg "mesa" "Mesa (OpenGL/Zink)"
    
    if [ "$GPU_DRIVER" == "freedreno" ]; then
        install_pkg "mesa-vulkan-icd-freedreno" "Turnip Driver"
    elif [ "$GPU_DRIVER" == "mali" ]; then
        draw_line "${CYAN}ℹ${NC} Hardware acceleration detected. Using System Vulkan + Zink."
    else
        install_pkg "mesa-vulkan-icd-swrast" "Software Vulkan"
    fi
    
    # Install Vulkan Loader with fallback
    (pkg install vulkan-loader -y) > /dev/null 2>&1 &
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
    
    # Determine Distro-Specific Aesthetics
    local GTK_COLOR="dark"
    local ICON_REPO=""
    local ICON_NAME="Papirus-Dark"
    local PANEL_POS="p=10;x=0;y=0" # Default Left (Ubuntu-style)
    local PANEL_SIZE=48
    local PANEL_LENGTH=100

    case "$PROOT_DISTRO" in
        "ubuntu")
            GTK_COLOR="orange"
            ICON_NAME="Papirus-Dark"
            PANEL_POS="p=10;x=0;y=0"
            PANEL_SIZE=48
            ;;
        "archlinux")
            GTK_COLOR="grey"
            ICON_REPO="https://github.com/vinceliuice/WhiteSur-icon-theme.git"
            ICON_NAME="WhiteSur-dark"
            PANEL_POS="p=2;x=0;y=0"
            PANEL_SIZE=32
            ;;
        "fedora")
            GTK_COLOR="blue"
            ICON_REPO="https://github.com/vinceliuice/WhiteSur-icon-theme.git"
            ICON_NAME="WhiteSur-dark"
            PANEL_POS="p=2;x=0;y=0"
            PANEL_SIZE=36
            ;;
        "deepin")
            GTK_COLOR="dark"
            ICON_REPO="https://github.com/vinceliuice/Fluent-icon-theme.git"
            ICON_NAME="Fluent-dark"
            PANEL_POS="p=6;x=0;y=0"
            PANEL_SIZE=52
            PANEL_LENGTH=80
            ;;
        *) # Debian or others
            GTK_COLOR="dark"
            ICON_NAME="Papirus-Dark"
            PANEL_POS="p=6;x=0;y=0"
            PANEL_SIZE=38
            ;;
    esac

    local THEME_NAME="Orchis-${GTK_COLOR}-Dark"
    [[ "$GTK_COLOR" == "dark" ]] && THEME_NAME="Orchis-Dark"

    draw_line "${YELLOW}⏳${NC} Cloning Orchis Theme (${GTK_COLOR})..."
    T_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/orchis-theme"
    rm -rf "$T_DIR"
    mkdir -p "$T_DIR"
    if git clone --depth 1 https://github.com/vinceliuice/Orchis-theme.git "$T_DIR" > /dev/null 2>&1; then
        cd "$T_DIR"
        find . -type f -name "*.sh" -exec termux-fix-shebang {} \; 2>/dev/null
        bash install.sh -d ~/.themes -c "$GTK_COLOR" -t dark > /dev/null 2>&1
        draw_line "${GREEN}✓${NC} Orchis ${GTK_COLOR} installed"
        cd - > /dev/null
    fi
    rm -rf "$T_DIR"

    if [[ -n "$ICON_REPO" ]]; then
        draw_line "${YELLOW}⏳${NC} Installing Custom Icons for ${PROOT_DISTRO}..."
        I_DIR="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/extra-icons"
        rm -rf "$I_DIR"
        if git clone --depth 1 "$ICON_REPO" "$I_DIR" > /dev/null 2>&1; then
            cd "$I_DIR"
            find . -type f -name "*.sh" -exec termux-fix-shebang {} \; 2>/dev/null
            bash install.sh -d ~/.icons > /dev/null 2>&1
            draw_line "${GREEN}✓${NC} Icons installed"
            cd - > /dev/null
        fi
        rm -rf "$I_DIR"
    fi

    draw_line "${YELLOW}⏳${NC} Applying XFCE configuration..."
    CONF_DIR="$HOME/.config/xfce4/xfconf/xfce-perchannel-xml"
    mkdir -p "$CONF_DIR"
    
    cat > "$CONF_DIR/xsettings.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="${THEME_NAME}"/>
    <property name="IconThemeName" type="string" value="${ICON_NAME}"/>
    <property name="CursorThemeName" type="string" value="Adwaita"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="DecorationLayout" type="string" value="close,minimize,maximize:"/>
  </property>
</channel>
EOF

    # Configure XFCE Panel Layout
    cat > "$CONF_DIR/xfce4-panel.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="${PANEL_POS}"/>
      <property name="length" type="double" value="${PANEL_LENGTH}"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="int" value="${PANEL_SIZE}"/>
      <property name="autohide-behavior" type="int" value="1"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="applicationsmenu"/>
    <property name="plugin-2" type="string" value="tasklist"/>
    <property name="plugin-3" type="string" value="separator">
      <property name="expand" type="bool" value="true"/>
      <property name="style" type="int" value="0"/>
    </property>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="clock"/>
  </property>
</channel>
EOF

    cat > "$CONF_DIR/xfwm4.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="${THEME_NAME}"/>
    <property name="title_alignment" type="string" value="center"/>
    <property name="button_layout" type="string" value="O|HMC"/>
  </property>
</channel>
EOF

    # Handle Wallpapers
    draw_line "${YELLOW}⏳${NC} Integrating Wallpapers..."
    mkdir -p ~/Pictures/Wallpapers
    if [ -d "./wallpapers" ]; then
        cp -r ./wallpapers/* ~/Pictures/Wallpapers/ 2>/dev/null
        draw_line "${GREEN}✓${NC} Local wallpapers copied to ~/Pictures/Wallpapers"
    fi

    # Determine wallpaper for the selected distro
    local WP_NAME="Standard"
    case "$PROOT_DISTRO" in
        "ubuntu") WP_NAME="Ubuntu" ;;
        "archlinux") WP_NAME="Arch" ;;
        "fedora") WP_NAME="Fedora" ;;
        "debian") WP_NAME="Debian" ;;
        "deepin") WP_NAME="Deepin" ;;
    esac
    
    local WP_PATH="/data/data/com.termux/files/home/Pictures/Wallpapers/Distros/${WP_NAME}.png"
    # Fallback if file doesn't exist
    [[ ! -f "$WP_PATH" ]] && WP_PATH="/data/data/com.termux/files/usr/share/backgrounds/xfce/xfce-verticals.png"

    cat > "$CONF_DIR/xfce4-desktop.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="color-style" type="int" value="0"/>
          <property name="image-style" type="int" value="5"/>
          <property name="last-image" type="string" value="${WP_PATH}"/>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="file-icons" type="empty">
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-home" type="bool" value="true"/>
      <property name="show-trash" type="bool" value="true"/>
    </property>
  </property>
</channel>
EOF

    cat > "$CONF_DIR/xfce4-power-manager.xml" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="dpms-enabled" type="bool" value="false"/>
    <property name="presentation-mode" type="bool" value="true"/>
  </property>
</channel>
EOF
    draw_bottom
}
# ============== STEP 10: INSTALL BROWSERS & APPS ==============
step_apps() {
    update_progress
    draw_box "Core Applications"
    install_pkg "git" "Git VSC"
    draw_bottom
}
# ============== STEP 8: INSTALL EXTRA APPS ==============
step_extra_apps() {
    [[ "$INSTALL_EXTRA_APPS" == "0" ]] || [[ -z "$INSTALL_EXTRA_APPS" ]] && return
    
    update_progress
    draw_box "Extra Applications"
    
    if [[ "$INSTALL_EXTRA_APPS" == *"1"* ]]; then
        install_pkg "firefox" "Firefox Browser"
    fi
    if [[ "$INSTALL_EXTRA_APPS" == *"2"* ]]; then
        install_pkg "chromium" "Chromium Browser"
    fi
    if [[ "$INSTALL_EXTRA_APPS" == *"3"* ]]; then
        install_pkg "code-oss" "VS Code"
    fi
    if [[ "$INSTALL_EXTRA_APPS" == *"4"* ]]; then
        install_pkg "gimp" "GIMP Editor"
    fi
    if [[ "$INSTALL_EXTRA_APPS" == *"5"* ]]; then
        install_pkg "vlc" "VLC Player"
    fi
    if [[ "$INSTALL_EXTRA_APPS" == *"7"* ]]; then
        install_pkg "inkscape" "Inkscape"
    fi
    if [[ "$INSTALL_EXTRA_APPS" == *"8"* ]]; then
        install_pkg "btop" "btop Monitor"
    fi
    if [[ "$INSTALL_EXTRA_APPS" == *"9"* ]]; then
        install_pkg "box64" "Box64 Emulation"
        install_pkg "wine-stable" "Wine (Windows Apps)"
    fi

    draw_bottom
}
# ============== STEP 12: INSTALL PROOT (OPTIONAL) ==============
step_proot() {
    update_progress
    draw_box "PRoot Subsystem (${PROOT_DISTRO})"
    
    install_pkg "proot-distro" "PRoot Manager"
    
    (proot-distro install ${PROOT_DISTRO}) > /dev/null 2>&1 &
    spinner $! "Installing ${PROOT_DISTRO}"
    
    if ! proot-distro login ${PROOT_DISTRO} -- bash -c "grep -q 'DEXLINUX_CONFIG' /etc/profile" > /dev/null 2>&1; then
        # Distro-specific configuration
        local PM_UPDATE="apt update"
        local PM_INSTALL="apt install -y"
        local PKG_BASE="sudo wget curl git mesa-utils locales"
        local PKG_EXTRA=""
        local LOCALE_CONF="update-locale LANG=${SYS_LOCALE}"

        if [[ "$PROOT_DISTRO" == "archlinux" ]]; then
            PM_UPDATE="pacman -Syu --noconfirm"
            PM_INSTALL="pacman -S --noconfirm"
            PKG_BASE="sudo shadow wget curl git mesa-utils"
            [[ "$INSTALL_EXTRA_APPS" == *"6"* ]] && PKG_EXTRA+=" libreoffice-fresh"
            [[ "$INSTALL_EXTRA_APPS" == *"7"* ]] && PKG_EXTRA+=" inkscape"
            [[ "$INSTALL_EXTRA_APPS" == *"8"* ]] && PKG_EXTRA+=" btop"
            LOCALE_CONF="echo 'LANG=${SYS_LOCALE}' > /etc/locale.conf"
        elif [[ "$PROOT_DISTRO" == "fedora" ]]; then
            PM_UPDATE="dnf update -y"
            PM_INSTALL="dnf install -y"
            PKG_BASE="sudo shadow-utils wget curl git mesa-utils glibc-all-langpacks"
            [[ "$INSTALL_EXTRA_APPS" == *"6"* ]] && PKG_EXTRA+=" libreoffice"
            [[ "$INSTALL_EXTRA_APPS" == *"7"* ]] && PKG_EXTRA+=" inkscape"
            [[ "$INSTALL_EXTRA_APPS" == *"8"* ]] && PKG_EXTRA+=" btop"
            LOCALE_CONF="echo 'LANG=${SYS_LOCALE}' > /etc/locale.conf"
        else
            [[ "$INSTALL_EXTRA_APPS" == *"6"* ]] && PKG_EXTRA+=" libreoffice libreoffice-gtk3"
            [[ "$INSTALL_EXTRA_APPS" == *"7"* ]] && PKG_EXTRA+=" inkscape"
            [[ "$INSTALL_EXTRA_APPS" == *"8"* ]] && PKG_EXTRA+=" btop"
        fi

        (proot-distro login ${PROOT_DISTRO} -- bash -c "
            ${PM_UPDATE} && ${PM_INSTALL} ${PKG_BASE} ${PKG_EXTRA} > /dev/null 2>&1
            if [[ "$PROOT_DISTRO" != "fedora" ]]; then
                # Robust locale generation: match with or without space after #
                sed -i \"s/^#\\s*${SYS_LOCALE}/${SYS_LOCALE}/\" /etc/locale.gen 2>/dev/null || true
                # Fallback: if not found, append it
                if ! grep -q \"^${SYS_LOCALE}\" /etc/locale.gen 2>/dev/null; then
                    echo \"${SYS_LOCALE} UTF-8\" >> /etc/locale.gen
                fi
                locale-gen > /dev/null 2>&1
            fi
            ${LOCALE_CONF}
            if ! id -u ${PROOT_USER} >/dev/null 2>&1; then
                useradd -m -s /bin/bash ${PROOT_USER}
                mkdir -p /etc/sudoers.d
                echo '${PROOT_USER} ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/${PROOT_USER}
                chmod 0440 /etc/sudoers.d/${PROOT_USER}
            fi
            echo \"export LANG=${SYS_LOCALE}\" >> /etc/profile
            echo \"export LC_ALL=${SYS_LOCALE}\" >> /etc/profile
            cat >> /etc/profile << 'EOF'
# DEXLINUX_CONFIG_START
export USER=\$(whoami)
export LOGNAME=\$USER
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
# DEXLINUX_CONFIG_END
EOF
            echo \"export PS1='\\[\\e[32m\\]\\u\\[\\e[m\\]@\\[\\e[34m\\]dexlinux\\[\\e[m\\]:\\[\\e[36m\\]\\w\\[\\e[m\\]\\$ '\" >> /etc/bash.bashrc
            
            # Sync themes and icons from Termux to Distro for consistency
            mkdir -p /home/${PROOT_USER}/.themes /home/${PROOT_USER}/.icons
            
            # GTK3 Settings for the distro user
            mkdir -p /home/${PROOT_USER}/.config/gtk-3.0
            cat > /home/${PROOT_USER}/.config/gtk-3.0/settings.ini << GTKEOF
[Settings]
gtk-theme-name=${THEME_NAME}
gtk-icon-theme-name=${ICON_NAME}
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-toolbar-style=GTK_TOOLBAR_ICONS
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=1
gtk-menu-images=1
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
GTKEOF
            chown -R ${PROOT_USER}:${PROOT_USER} /home/${PROOT_USER}/.themes /home/${PROOT_USER}/.icons /home/${PROOT_USER}/.config
        ") > /dev/null 2>&1 &
        spinner $! "Bootstrapping environment"
        
        # Physical copy of themes/icons from Termux to PRoot (run from Termux)
        # This ensures the distro actually has the files
        print_status "🎨" "Syncing visual assets to ${PROOT_DISTRO}..."
        proot-distro login ${PROOT_DISTRO} -- bash -c "mkdir -p /home/${PROOT_USER}/.themes /home/${PROOT_USER}/.icons"
        cp -r ~/.themes/* $(proot-distro info ${PROOT_DISTRO} | grep "rootfs:" | awk '{print $2}')/home/${PROOT_USER}/.themes/ 2>/dev/null
        cp -r ~/.icons/* $(proot-distro info ${PROOT_DISTRO} | grep "rootfs:" | awk '{print $2}')/home/${PROOT_USER}/.icons/ 2>/dev/null
    fi

    # Create a wrapper script for easier access and debugging
    cat > ~/dexlinux-shell-${PROOT_DISTRO}.sh << EOF
#!/data/data/com.termux/files/usr/bin/bash
export DISPLAY=:0
source ~/.config/dexlinux-gpu.sh
proot-distro login ${PROOT_DISTRO} --user ${PROOT_USER}
EOF
    chmod +x ~/dexlinux-shell-${PROOT_DISTRO}.sh

    D_NAME=$(echo "$PROOT_DISTRO" | sed 's/./\U&/')
    cat > ~/Desktop/${D_NAME}.desktop << EOF
[Desktop Entry]
Name=${D_NAME} Shell
Comment=Open ${D_NAME} environment
Exec=xfce4-terminal --title="${D_NAME} Shell" --command="bash /data/data/com.termux/files/home/dexlinux-shell-${PROOT_DISTRO}.sh"
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
export LANG=DEX_LANG_PLACEHOLDER
export LC_ALL=DEX_LANG_PLACEHOLDER
export XDG_DATA_DIRS=/data/data/com.termux/files/usr/share:${XDG_DATA_DIRS}
export XDG_CONFIG_DIRS=/data/data/com.termux/files/usr/etc/xdg:${XDG_CONFIG_DIRS}
GPUEOF
    draw_line "${GREEN}✓${NC} GPU config created"
    
    if ! grep -q "dexlinux-gpu.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/dexlinux-gpu.sh 2>/dev/null' >> ~/.bashrc
    fi
    
    # Customize Termux Prompt to hide u0_aXXX
    sed -i '/export PS1=/d' ~/.bashrc 2>/dev/null
    echo "export PS1=\"\\[\\e[32m\\]\${USER:-dex}\\[\\e[m\\]@\\[\\e[34m\\]dexlinux\\[\\e[m\\]:\\[\\e[36m\\]\\w\\[\\e[m\\]\\$ \"" >> ~/.bashrc
    
    # Main Launcher
    cat > ~/start-dexlinux.sh << 'LAUNCHEREOF'
#!/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting DexLinux Desktop..."
export USER="${PROOT_USER:-dex}"
export LOGNAME="${PROOT_USER:-dex}"
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
export LANG=DEX_LANG_PLACEHOLDER
export LC_ALL=DEX_LANG_PLACEHOLDER
setxkbmap DEX_KBD_PLACEHOLDER 2>/dev/null
exec startxfce4 > /dev/null 2>&1
LAUNCHEREOF
    sed -i "s/DEX_KBD_PLACEHOLDER/${SYS_KBD}/g" ~/start-dexlinux.sh
    sed -i "s/DEX_LANG_PLACEHOLDER/${SYS_LOCALE}/g" ~/start-dexlinux.sh
    sed -i "s/DEX_LANG_PLACEHOLDER/${SYS_LOCALE}/g" ~/.config/dexlinux-gpu.sh
    chmod +x ~/start-dexlinux.sh
    draw_line "${GREEN}✓${NC} Created ~/start-dexlinux.sh"
    
    # Termux:Widget Shortcut
    mkdir -p ~/.shortcuts
    cat > ~/.shortcuts/Start_DexLinux << 'WIDGETEOF'
#!/data/data/com.termux/files/usr/bin/bash
bash ~/start-dexlinux.sh
WIDGETEOF
    chmod +x ~/.shortcuts/Start_DexLinux
    draw_line "${GREEN}✓${NC} Created Android Widget Shortcut"
    
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
    echo "║  1) 🖥️  Start Desktop                     ║"
    echo "║  2) 📏 Change Resolution (xrandr)         ║"
    echo "║  3) 🔍 Check GPU Status                   ║"
    echo "║  0) ❌ Exit                               ║"
    echo "╚═══════════════════════════════════════════╝"
    read -p "  Select option: " choice
    case $choice in
        1) bash ~/start-dexlinux.sh;;
        2) bash ~/dex-res.sh;;
        3) glxinfo | grep "renderer"; read -p "Enter...";;
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
Comment=System Tools
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
    
    if [[ "$INSTALL_EXTRA_APPS" != *"0"* ]] && [[ -n "$INSTALL_EXTRA_APPS" ]]; then
        step_extra_apps
    fi
    
    [[ "$INSTALL_PROOT" == "true" ]] && step_proot

    
    step_launchers
    step_shortcuts
    step_firstrun
    
    show_completion
}
# ============== RUN ==============
main
