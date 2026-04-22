# !/data/data/com.termux/files/usr/bin/bash
#######################################################
# Android Linux Desktop
#######################################################

# ============== CONFIGURATION ==============
TOTAL_STEPS=15
CURRENT_STEP=0
PROOT_CHOICE="0"
PROOT_DISTRO=""
PROOT_LABEL=""
SETUP_USERNAME="root"
SELECTED_APPS=""
INSTALL_LOG="${TMPDIR:-/data/data/com.termux/files/usr/tmp}/mobile_desktop_install.log"

# ============== COLORS ==============
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
NC='\033[0m'
BOLD='\033[1m'

# Update overall progress
update_progress() {
    CURRENT_STEP=$((CURRENT_STEP + 1))
    PERCENT=$((CURRENT_STEP * 100 / TOTAL_STEPS))

    # Create progress bar
    FILLED=$((PERCENT / 5))
    EMPTY=$((20 - FILLED))

    BAR="${GREEN}"
    for ((i=0; i<FILLED; i++)); do BAR+="█"; done
    BAR+="${GRAY}"
    for ((i=0; i<EMPTY; i++)); do BAR+="░"; done
    BAR+="${NC}"

    echo ""
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📊 OVERALL PROGRESS: ${WHITE}Step ${CURRENT_STEP}/${TOTAL_STEPS}${NC} ${BAR} ${WHITE}${PERCENT}%${NC}"
    echo -e "${WHITE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Spinner animation for running tasks
spinner() {
    local pid=$1
    local message=$2
    local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    local i=0

    while kill -0 $pid 2>/dev/null; do
        i=$(( (i+1) % 10 ))
        printf "\r  ${YELLOW}⏳${NC} ${message} ${CYAN}${spin:$i:1}${NC}  "
        sleep 0.1
    done

    wait $pid
    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        printf "\r  ${GREEN}✓${NC} ${message}                    \n"
    else
        printf "\r  ${RED}✗${NC} ${message} ${RED}(failed)${NC}     \n"
    fi

    return $exit_code
}

# Install packages with progress
# Optimized to accept multiple packages at once for speed
install_pkg() {
    local pkgs=$1
    local name=$2

    (pkg install -y $pkgs >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Installing ${name}..."
}

# ============== BANNER ==============
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'BANNER'
    ╔══════════════════════════════════════╗
    ║                                      ║
    ║  🤖 Android Linux Desktop v1.0 🐧   ║
    ║                                      ║
    ║            Luigifaria88              ║
    ║                                      ║
    ╚══════════════════════════════════════╝
BANNER

    echo -e "${NC}"
    echo -e "${WHITE}         Luigifaria88${NC}"
    echo ""
}

# ============== CHOOSE DESKTOP ==============
choose_desktop() {
    clear
    show_banner
    echo -e "${CYAN}=== ESCOLHA O AMBIENTE GRÁFICO ===${NC}"
    echo -e "${WHITE}1) XFCE4${NC} (Recomendado, Leve e Estável)"
    echo -e "${WHITE}2) LXQt${NC}  (Leve, baseado em Qt)"
    echo -e "${WHITE}3) MATE${NC}  (Clássico, fork do GNOME 2)"
    echo -e "${WHITE}4) KDE Plasma${NC} (Moderno, Pesado)"
    echo ""
    read -p "Selecione uma opção [1-4] (Padrão: 1): " DE_CHOICE

    case $DE_CHOICE in
        2) 
            DESKTOP_ENV="lxqt"
            DESKTOP_NAME="LXQt"
            DESKTOP_CMD="startlxqt"
            ;;
        3) 
            DESKTOP_ENV="mate"
            DESKTOP_NAME="MATE"
            DESKTOP_CMD="mate-session"
            ;;
        4) 
            DESKTOP_ENV="kde"
            DESKTOP_NAME="KDE Plasma"
            DESKTOP_CMD="startplasma-x11"
            ;;
        *) 
            DESKTOP_ENV="xfce4"
            DESKTOP_NAME="XFCE4"
            DESKTOP_CMD="startxfce4"
            ;;
    esac
    
    echo -e "  ${GREEN}✓${NC} Ambiente selecionado: ${WHITE}${DESKTOP_NAME}${NC}"
    sleep 1
}

# ============== CHOOSE PROOT DISTRO ==============
choose_proot_distro() {
    clear
    show_banner
    echo -e "${CYAN}=== ESCOLHA UMA DISTRIBUIÇÃO LINUX VIA PROOT ===${NC}"
    echo -e "${WHITE}0) Nenhuma${NC} (Apenas interface nativa)"
    echo -e "${WHITE}1) Ubuntu${NC} (Recomendado)"
    echo -e "${WHITE}2) Debian${NC} (Estável, Leve)"
    echo -e "${WHITE}3) Arch Linux${NC} (Rolling release, pacman)"
    echo -e "${WHITE}4) Fedora${NC} (Moderna, dnf)"
    echo -e "${WHITE}5) Manjaro${NC} (Arch amigável)"
    echo -e "${WHITE}6) OpenSUSE${NC} (zypper)"
    echo -e "${WHITE}7) Deepin${NC} (Avançado)"
    echo ""
    read -p "Selecione uma opção [0-7] (Padrão: 0): " PROOT_CHOICE
    
    PROOT_CHOICE=${PROOT_CHOICE:-0}

    case $PROOT_CHOICE in
        1) PROOT_DISTRO="ubuntu"; PROOT_LABEL="Ubuntu";;
        2) PROOT_DISTRO="debian"; PROOT_LABEL="Debian";;
        3) PROOT_DISTRO="archlinux"; PROOT_LABEL="Arch Linux";;
        4) PROOT_DISTRO="fedora"; PROOT_LABEL="Fedora";;
        5) PROOT_DISTRO="manjaro"; PROOT_LABEL="Manjaro";;
        6) PROOT_DISTRO="opensuse"; PROOT_LABEL="OpenSUSE";;
        7) PROOT_DISTRO="deepin"; PROOT_LABEL="Deepin";;
        *) PROOT_DISTRO=""; PROOT_LABEL="Nenhuma";;
    esac

    echo -e "  ${GREEN}✓${NC} Distribuição PRoot selecionada: ${WHITE}${PROOT_LABEL}${NC}"
    
    if [ "$PROOT_CHOICE" != "0" ]; then
        echo ""
        read -p "Digite o nome de utilizador para a distro Linux (Padrão: root): " SETUP_USERNAME
        SETUP_USERNAME=${SETUP_USERNAME:-root}
    echo -e "  ${GREEN}✓${NC} Utilizador definido: ${WHITE}${SETUP_USERNAME}${NC}"
    fi
    sleep 1
}

# ============== CHOOSE ADDITIONAL APPS ==============
choose_additional_apps() {
    clear
    show_banner
    echo -e "${CYAN}=== ESCOLHA APLICAÇÕES ADICIONAIS PARA INSTALAR ===${NC}"
    echo -e "${GRAY}(Instaladas no PRoot se ativo, ou nativamente no Termux)${NC}"
    echo ""
    echo -e "${WHITE}1) GIMP${NC} (Editor de Imagem)"
    echo -e "${WHITE}2) LibreOffice${NC} (Suíte de Escritório)"
    echo -e "${WHITE}3) VLC${NC} (Reprodutor Multimédia)"
    echo -e "${WHITE}4) Blender${NC} (Modelação 3D)"
    echo -e "${WHITE}5) Inkscape${NC} (Vetores)"
    echo -e "${WHITE}6) Nenhuma / Concluir${NC}"
    echo ""
    
    while true; do
        read -p "Selecione uma app por vez [1-6]: " APP_PICK
        case $APP_PICK in
            1) SELECTED_APPS+=( "gimp" ); echo -e "  ${GREEN}+${NC} GIMP adicionado";;
            2) SELECTED_APPS+=( "libreoffice" ); echo -e "  ${GREEN}+${NC} LibreOffice adicionado";;
            3) SELECTED_APPS+=( "vlc" ); echo -e "  ${GREEN}+${NC} VLC adicionado";;
            4) SELECTED_APPS+=( "blender" ); echo -e "  ${GREEN}+${NC} Blender adicionado";;
            5) SELECTED_APPS+=( "inkscape" ); echo -e "  ${GREEN}+${NC} Inkscape adicionado";;
            6|"") break;;
            *) echo -e "${RED}[!] Opção inválida${NC}";;
        esac
    done
    echo ""
    echo -e "  ${GREEN}✓${NC} Seleção de software concluída."
    sleep 1
}

# ============== DEVICE DETECTION ==============
detect_device() {
    echo -e "${PURPLE}[*] Detecting your device...${NC}"
    echo ""

    DEVICE_MODEL=$(getprop ro.product.model 2>/dev/null || echo "Unknown")
    DEVICE_BRAND=$(getprop ro.product.brand 2>/dev/null || echo "Unknown")
    ANDROID_VERSION=$(getprop ro.build.version.release 2>/dev/null || echo "Unknown")
    CPU_ABI=$(getprop ro.product.cpu.abi 2>/dev/null || echo "arm64-v8a")

    # Storage Check
    FREE_SPACE=$(df -m /data | awk 'NR==2 {print $4}')
    TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')

    echo -e "  ${GREEN}📱${NC} Device: ${WHITE}${DEVICE_BRAND} ${DEVICE_MODEL}${NC}"
    echo -e "  ${GREEN}🤖${NC} Android: ${WHITE}${ANDROID_VERSION}${NC}"
    echo -e "  ${GREEN}⚙️${NC}  CPU: ${WHITE}${CPU_ABI}${NC}"
    echo -e "  ${GREEN}💾${NC} RAM: ${WHITE}${TOTAL_RAM}MB${NC}"
    echo -e "  ${GREEN}💽${NC} Espaço Livre: ${WHITE}${FREE_SPACE}MB${NC}"

    # Warnings
    if [ "$FREE_SPACE" -lt 5000 ]; then
        echo -e "\n  ${YELLOW}⚠️  AVISO: Pouco espaço livre (menos de 5GB). A instalação pode falhar.${NC}"
    fi
    if [ "$TOTAL_RAM" -lt 4000 ] && [ "$DESKTOP_ENV" == "kde" ]; then
        echo -e "\n  ${YELLOW}⚠️  AVISO: O KDE Plasma corre melhor com mais de 4GB de RAM.${NC}"
    fi

    # Determine GPU driver
    if [[ "$GPU_VENDOR" == *"adreno"* ]] || [[ "$DEVICE_BRAND" == *"samsung"* ]] || [[ "$DEVICE_BRAND" == *"Samsung"* ]] || [[ "$DEVICE_BRAND" == *"oneplus"* ]] || [[ "$DEVICE_BRAND" == *"xiaomi"* ]]; then
        GPU_DRIVER="freedreno"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Adreno (Qualcomm) - Turnip driver${NC}"
    else
        GPU_DRIVER="swrast"
        echo -e "  ${GREEN}🎮${NC} GPU: ${WHITE}Software rendering${NC}"
    fi

    echo ""
    sleep 1
}

# ============== STEP 1: UPDATE SYSTEM ==============
step_update() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Updating system packages...${NC}"
    echo ""

    # Limpar log antigo
    > "$INSTALL_LOG"

    (pkg update -y >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Updating package lists..."

    (pkg upgrade -y >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Upgrading installed packages..."
}

# ============== STEP 2: INSTALL REPOSITORIES ==============
step_repos() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Adding package repositories...${NC}"
    echo ""

    install_pkg "x11-repo tur-repo" "Extra Repositories (X11 & TUR)"
    
    # Reload package lists after adding repos
    (pkg update -y >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Refreshing package lists..."
}

# ============== STEP 3: INSTALL TERMUX-X11 ==============
step_x11() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Termux-X11...${NC}"
    echo ""

    install_pkg "termux-x11-nightly xorg-xrandr" "Termux-X11 Display Server"
}

# ============== STEP 4: INSTALL DESKTOP ==============
step_desktop() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing ${DESKTOP_NAME} Desktop...${NC}"
    echo ""

    # Optimized to install all components in a single transaction
    if [ "$DESKTOP_ENV" == "xfce4" ]; then
        install_pkg "xfce4 xfce4-terminal thunar mousepad dbus-x11" "XFCE4 Desktop & Utils"
    elif [ "$DESKTOP_ENV" == "lxqt" ]; then
        install_pkg "lxqt qterminal pcmanfm-qt mousepad dbus-x11" "LXQt Desktop & Utils"
    elif [ "$DESKTOP_ENV" == "mate" ]; then
        install_pkg "mate-desktop mate-terminal caja mousepad dbus-x11" "MATE Desktop & Utils"
    elif [ "$DESKTOP_ENV" == "kde" ]; then
        install_pkg "plasma konsole dolphin mousepad dbus-x11" "KDE Plasma Desktop & Utils"
    fi
}

# ============== STEP 5: INSTALL GPU DRIVERS ==============
step_gpu() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing GPU Acceleration (Turnip/Zink)...${NC}"
    echo ""

    if [ "$GPU_DRIVER" == "freedreno" ]; then
        GPU_PKG="mesa-vulkan-icd-freedreno"
    else
        GPU_PKG="mesa-vulkan-icd-swrast"
    fi

    install_pkg "mesa-zink $GPU_PKG vulkan-loader-android" "Mesa 3D Graphics Library"

    echo -e "  ${GREEN}✓${NC} GPU acceleration configured!"
}

# ============== STEP 6: INSTALL AUDIO ==============
step_audio() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Audio Support...${NC}"
    echo ""

    install_pkg "pulseaudio" "PulseAudio Sound Server"
}

# ============== STEP 7: INSTALL BROWSERS & APPS ==============
step_apps() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing Applications...${NC}"
    echo ""

    install_pkg "firefox code-oss git wget curl" "Web & Dev Tools"
}

# ============== STEP 8: INSTALL PROOT DISTRO ==============
step_proot() {
    if [ "$PROOT_CHOICE" == "0" ]; then
        return
    fi

    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Installing ${PROOT_LABEL} via PRoot...${NC}"
    echo ""

    install_pkg "proot-distro proot" "PRoot Framework"

    echo -e "\n  ${YELLOW}⏳${NC} A descarregar e instalar ${PROOT_LABEL} (pode demorar)..."
    (proot-distro install "$PROOT_DISTRO" >> "$INSTALL_LOG" 2>&1) &
    spinner $! "A instalar o sistema base da distribuição..."

    echo -e "  ${YELLOW}⏳${NC} A configurar e aplicar personalizações extremas em ${PROOT_LABEL}..."
    
    # Comandos baseados no gestor de pacotes da distro selecionada
    if [[ "$PROOT_DISTRO" == "ubuntu" || "$PROOT_DISTRO" == "debian" || "$PROOT_DISTRO" == "deepin" ]]; then
        SETUP_CMD="
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -y -q > /dev/null 2>&1
        apt-get upgrade -y -q > /dev/null 2>&1
        apt-get install -y -q sudo curl wget git htop nano neofetch software-properties-common dbus-x11 mesa-utils locales > /dev/null 2>&1
        echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen > /dev/null 2>&1
        echo 'alias ll=\"ls -la\"' >> /etc/bash.bashrc
        echo 'alias update=\"sudo apt update && sudo apt upgrade -y\"' >> /etc/bash.bashrc
        echo 'export LANG=en_US.UTF-8' >> /etc/bash.bashrc
        echo 'export LC_ALL=en_US.UTF-8' >> /etc/bash.bashrc
        echo 'export PS1=\"\[\e[1;32m\]\u@\h\[\e[m\]:\[\e[1;34m\]\w\[\e[m\]\$ \"' >> /etc/bash.bashrc
        "
    elif [[ "$PROOT_DISTRO" == "archlinux" || "$PROOT_DISTRO" == "manjaro" ]]; then
        SETUP_CMD="
        pacman-key --init > /dev/null 2>&1
        pacman-key --populate > /dev/null 2>&1
        pacman -Syu --noconfirm > /dev/null 2>&1
        pacman -S --noconfirm sudo curl wget git htop nano neofetch dbus mesa-utils > /dev/null 2>&1
        echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && locale-gen > /dev/null 2>&1
        echo 'alias ll=\"ls -la\"' >> /etc/bash.bashrc
        echo 'alias update=\"sudo pacman -Syu --noconfirm\"' >> /etc/bash.bashrc
        echo 'export LANG=en_US.UTF-8' >> /etc/bash.bashrc
        echo 'export LC_ALL=en_US.UTF-8' >> /etc/bash.bashrc
        echo 'export PS1=\"\[\e[1;32m\]\u@\h\[\e[m\]:\[\e[1;34m\]\w\[\e[m\]\$ \"' >> /etc/bash.bashrc
        "
    elif [[ "$PROOT_DISTRO" == "fedora" ]]; then
        SETUP_CMD="
        dnf update -y > /dev/null 2>&1
        dnf install -y sudo curl wget git htop nano neofetch dbus-x11 mesa-utils glibc-langpack-en > /dev/null 2>&1
        echo 'alias ll=\"ls -la\"' >> /etc/bashrc
        echo 'alias update=\"sudo dnf update -y\"' >> /etc/bashrc
        echo 'export LANG=en_US.UTF-8' >> /etc/bashrc
        echo 'export LC_ALL=en_US.UTF-8' >> /etc/bashrc
        echo 'export PS1=\"\[\e[1;32m\]\u@\h\[\e[m\]:\[\e[1;34m\]\w\[\e[m\]\$ \"' >> /etc/bashrc
        "
    elif [[ "$PROOT_DISTRO" == "opensuse" ]]; then
        SETUP_CMD="
        zypper refresh > /dev/null 2>&1
        zypper update -y > /dev/null 2>&1
        zypper install -y sudo curl wget git htop nano neofetch dbus-1-x11 Mesa-demo-x glibc-locale > /dev/null 2>&1
        echo 'alias ll=\"ls -la\"' >> /etc/bash.bashrc
        echo 'alias update=\"sudo zypper update -y\"' >> /etc/bash.bashrc
        echo 'export LANG=en_US.UTF-8' >> /etc/bash.bashrc
        echo 'export LC_ALL=en_US.UTF-8' >> /etc/bash.bashrc
        echo 'export PS1=\"\[\e[1;32m\]\u@\h\[\e[m\]:\[\e[1;34m\]\w\[\e[m\]\$ \"' >> /etc/bash.bashrc
        "
    fi

    proot-distro login "$PROOT_DISTRO" -- bash -c "$SETUP_CMD" 2>/dev/null || true

    # Criação do utilizador e configuração de sudoers
    if [ "$SETUP_USERNAME" != "root" ]; then
        echo -e "  ${YELLOW}⏳${NC} A configurar o utilizador ${SETUP_USERNAME} com previlégios sudo..."
        proot-distro login "$PROOT_DISTRO" -- bash -c "
            id '$SETUP_USERNAME' > /dev/null 2>&1 || useradd -m -s /bin/bash '$SETUP_USERNAME'
            usermod -aG sudo,wheel '$SETUP_USERNAME' 2>/dev/null || true
            mkdir -p /etc/sudoers.d
            echo 'Defaults !requiretty' > /etc/sudoers.d/proot-compat
            echo '$SETUP_USERNAME ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/proot-compat
            chmod 0440 /etc/sudoers.d/proot-compat
            chmod u+s /usr/bin/sudo 2>/dev/null || true
            cp /etc/bashrc /home/$SETUP_USERNAME/.bashrc 2>/dev/null || true
            cp /etc/bash.bashrc /home/$SETUP_USERNAME/.bashrc 2>/dev/null || true
            chown -R $SETUP_USERNAME:$SETUP_USERNAME /home/$SETUP_USERNAME 2>/dev/null || true
        " 2>/dev/null || true
    fi

    if [ "$GPU_DRIVER" == "freedreno" ]; then
        GPU_EXTRA_ENV="export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
[ -f /usr/share/vulkan/icd.d.termux/freedreno_icd.aarch64.json ] && export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d.termux/freedreno_icd.aarch64.json"
    else
        GPU_EXTRA_ENV="export GALLIUM_DRIVER=llvmpipe
export LIBGL_ALWAYS_SOFTWARE=1"
    fi

    # Script de arranque PRoot nativo
    cat > ~/start-proot.sh << PROOTEOF
# !/data/data/com.termux/files/usr/bin/bash
export PROOT_DISTRO="$PROOT_DISTRO"
export PROOT_LABEL="$PROOT_LABEL"

echo ""
echo "============================================="
echo "  [*] A Iniciar \$PROOT_LABEL Terminal"
echo "============================================="
echo ""

TERMUX_TMP="\${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
TERMUX_VK_ICD="/data/data/com.termux/files/usr/share/vulkan/icd.d"

BINDS=""
[ -d "\\\$TERMUX_TMP/.X11-unix" ] && BINDS="\\\$BINDS --bind \\\$TERMUX_TMP/.X11-unix:/tmp/.X11-unix"
[ -d "/dev/dri" ]               && BINDS="\\\$BINDS --bind /dev/dri:/dev/dri"
[ -e "/dev/kgsl-3d0" ]          && BINDS="\\\$BINDS --bind /dev/kgsl-3d0:/dev/kgsl-3d0"
[ -d "\\\$TERMUX_VK_ICD" ]       && BINDS="\\\$BINDS --bind \\\$TERMUX_VK_ICD:/usr/share/vulkan/icd.d.termux"

_RC=\\\$(mktemp /data/data/com.termux/files/usr/tmp/proot_rc.XXXX)
cat > "\\\$_RC" << 'RCEOF'
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export MESA_NO_ERROR=1
$GPU_EXTRA_ENV
export XDG_DATA_DIRS=/usr/share:/usr/local/share:\${XDG_DATA_DIRS}
echo " Bem-vindo ao $PROOT_LABEL (\\\$(uname -a))"
echo " Escreva 'exit' para fechar."
echo ""
RCEOF

proot-distro login "\\\$PROOT_DISTRO" \\\$BINDS --user $SETUP_USERNAME -- bash --rcfile "\\\$_RC"
rm -f "\\\$_RC"
PROOTEOF
    chmod +x ~/start-proot.sh
    echo -e "  ${GREEN}✓${NC} Launcher ~/start-proot.sh criado!"
}

# ============== STEP 9: PROOT MENU BRIDGE ==============
step_proot_bridge() {
    if [ "$PROOT_CHOICE" == "0" ]; then
        return
    fi

    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Instalando App Bridge para Sincronizar Menus...${NC}"
    echo ""

    cat > ~/proot-menu-sync.sh << 'SYNCEOF'
# !/data/data/com.termux/files/usr/bin/bash
PROOT_DISTRO="${1:-ubuntu}"
PROOT_BIN="/data/data/com.termux/files/usr/bin/proot-distro"
PROOT_ROOTFS="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/$PROOT_DISTRO"
PROOT_APPS="$PROOT_ROOTFS/usr/share/applications"
BRIDGE_DIR="$HOME/.local/share/applications/proot-bridge"
WRAPPER_DIR="$HOME/.local/share/proot-wrappers"
TERMUX_TMP="${TMPDIR:-/data/data/com.termux/files/usr/tmp}"

if [ ! -d "$PROOT_ROOTFS" ]; then
    echo "Proot distro '$PROOT_DISTRO' not installed."
    exit 1
fi

mkdir -p "$BRIDGE_DIR" "$WRAPPER_DIR"

SYNCED=0
REMOVED=0

for bridge_file in "$BRIDGE_DIR"/proot-*.desktop; do
    [ -f "$bridge_file" ] || continue
    original_name=$(basename "$bridge_file" | sed 's/^proot-//')
    if [ ! -f "$PROOT_APPS/$original_name" ]; then
        rm -f "$bridge_file" "$WRAPPER_DIR/proot-${original_name%.desktop}.sh"
        REMOVED=$((REMOVED + 1))
    fi
done

for desktop_file in "$PROOT_APPS"/*.desktop; do
    [ -f "$desktop_file" ] || continue

    filename=$(basename "$desktop_file")
    appname="${filename%.desktop}"
    output="$BRIDGE_DIR/proot-$filename"
    wrapper="$WRAPPER_DIR/proot-${appname}.sh"

    grep -q "^NoDisplay=true" "$desktop_file" 2>/dev/null && continue
    grep -q "^Hidden=true"    "$desktop_file" 2>/dev/null && continue

    ORIGINAL_EXEC=$(grep "^Exec=" "$desktop_file" | head -1 | sed 's/^Exec=//')
    [ -z "$ORIGINAL_EXEC" ] && continue
    CLEAN_EXEC=$(echo "$ORIGINAL_EXEC" | sed 's/ %[a-zA-Z]//g; s/%[a-zA-Z]//g')

    APP_CMD="$CLEAN_EXEC"

    cat > "$wrapper" << WRAPEOF
# !/data/data/com.termux/files/usr/bin/bash
PROOT_BIN="$PROOT_BIN"
PROOT_DISTRO="$PROOT_DISTRO"
TERMUX_TMP="\${TMPDIR:-/data/data/com.termux/files/usr/tmp}"
LOG="\$TERMUX_TMP/proot-${appname}.log"

BINDS=""
X11_DIR="\$TERMUX_TMP/.X11-unix"
[ -d "\$X11_DIR" ]     && BINDS="\$BINDS --bind \$X11_DIR:/tmp/.X11-unix"
[ -d "/dev/dri" ]      && BINDS="\$BINDS --bind /dev/dri:/dev/dri"
[ -e "/dev/kgsl-3d0" ] && BINDS="\$BINDS --bind /dev/kgsl-3d0:/dev/kgsl-3d0"

{
\$PROOT_BIN login "\$PROOT_DISTRO" \$BINDS -- /bin/bash -c "
export DISPLAY=:0
export PULSE_SERVER=127.0.0.1
export XDG_RUNTIME_DIR=/tmp
export MESA_NO_ERROR=1
if [ \"$GPU_DRIVER\" == \"freedreno\" ]; then
    export GALLIUM_DRIVER=zink
    export MESA_LOADER_DRIVER_OVERRIDE=zink
else
    export GALLIUM_DRIVER=llvmpipe
    export LIBGL_ALWAYS_SOFTWARE=1
fi
dbus-run-session $APP_CMD
"
} > "\$LOG" 2>&1
WRAPEOF
    chmod +x "$wrapper"

    cp "$desktop_file" "$output"
    sed -i \
        -e "s|^Exec=.*|Exec=$wrapper|" \
        -e "s|^TryExec=.*|TryExec=$wrapper|" \
        -e '/^NoDisplay=/d' -e '/^Hidden=/d' \
        "$output"
    echo "NoDisplay=false" >> "$output"

    APP_NAME=$(grep "^Name=" "$output" | head -1 | sed 's/^Name=//')
    [[ "$APP_NAME" != \[P\]* ]] && sed -i "s|^Name=.*|Name=[P] $APP_NAME|" "$output"
    SYNCED=$((SYNCED + 1))
done

echo "[+] Bridge: $SYNCED apps sincronizadas."

pgrep -x "xfce4-panel" > /dev/null 2>&1 && xfce4-panel --restart > /dev/null 2>&1 &
pgrep -x "xfdesktop"   > /dev/null 2>&1 && { sleep 1; xfdesktop --reload > /dev/null 2>&1 & }
SYNCEOF
    chmod +x ~/proot-menu-sync.sh
    echo -e "  ${GREEN}✓${NC} Bridge ~/proot-menu-sync.sh criado e instalado!"

    # Executa pela primeira vez
    bash ~/proot-menu-sync.sh "$PROOT_DISTRO" 2>/dev/null || true
}

# ============== STEP 10: CREATE LAUNCHER SCRIPTS ==============
step_launchers() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Creating Launcher Scripts...${NC}"
    echo ""

    # GPU Configuration file
    mkdir -p ~/.config
    cat > ~/.config/gpu-config.sh << 'GPUEOF'

# Mobile Desktop - GPU Acceleration Config
export MESA_NO_ERROR=1
export MESA_GL_VERSION_OVERRIDE=4.6
export MESA_GLES_VERSION_OVERRIDE=3.2
export GALLIUM_DRIVER=zink
export MESA_LOADER_DRIVER_OVERRIDE=zink
export TU_DEBUG=noconform
export MESA_VK_WSI_PRESENT_MODE=immediate
export ZINK_DESCRIPTORS=lazy
GPUEOF
    echo -e "  ${GREEN}✓${NC} GPU config created"

    # Add to bashrc
    if ! grep -q "gpu-config.sh" ~/.bashrc 2>/dev/null; then
        echo 'source ~/.config/gpu-config.sh 2>/dev/null' >> ~/.bashrc
    fi

    # Main Desktop Launcher - AUDIO FIXED
    cat > ~/start-desktop.sh << LAUNCHEREOF

# !/data/data/com.termux/files/usr/bin/bash
echo ""
echo "🚀 Starting Mobile Linux Desktop (${DESKTOP_NAME})..."
echo ""

# Load GPU config
source ~/.config/gpu-config.sh 2>/dev/null

# Kill any existing sessions
echo "🔄 Cleaning up old sessions..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "lxqt" 2>/dev/null
pkill -9 -f "mate" 2>/dev/null
pkill -9 -f "plasma" 2>/dev/null
pkill -9 -f "kwin" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null

# === AUDIO SETUP ===
unset PULSE_SERVER
pulseaudio --kill 2>/dev/null
sleep 0.5
echo "🔊 Starting audio server..."
pulseaudio --start --exit-idle-time=-1
sleep 1
pactl load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1 2>/dev/null
export PULSE_SERVER=127.0.0.1

# Start Termux-X11 server
echo "📺 Starting X11 display server..."
termux-x11 :0 -ac &
sleep 3

# Set display
export DISPLAY=:0

# Start Desktop
echo "🖥️ Launching ${DESKTOP_NAME} Desktop..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Sync PRoot Apps se o proot estiver instalado
if [ -f ~/proot-menu-sync.sh ]; then
    bash ~/proot-menu-sync.sh "\$PROOT_DISTRO" > /dev/null 2>&1 &
fi

exec ${DESKTOP_CMD}
LAUNCHEREOF
    chmod +x ~/start-desktop.sh
    echo -e "  ${GREEN}✓${NC} Created ~/start-desktop.sh"

    # Desktop Shutdown Script
    cat > ~/stop-desktop.sh << 'STOPEOF'

# !/data/data/com.termux/files/usr/bin/bash
echo "Stopping Mobile Desktop..."
pkill -9 -f "termux.x11" 2>/dev/null
pkill -9 -f "pulseaudio" 2>/dev/null
pkill -9 -f "xfce" 2>/dev/null
pkill -9 -f "lxqt" 2>/dev/null
pkill -9 -f "mate" 2>/dev/null
pkill -9 -f "plasma" 2>/dev/null
pkill -9 -f "kwin" 2>/dev/null
pkill -9 -f "dbus" 2>/dev/null
echo "Desktop stopped."
STOPEOF
    chmod +x ~/stop-desktop.sh
    echo -e "  ${GREEN}✓${NC} Created ~/stop-desktop.sh"
}

# ============== STEP 11: APPLY MODERN THEMES (XFCE ONLY) ==============
step_theme() {
    if [ "$DESKTOP_ENV" != "xfce4" ]; then
        return
    fi

    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Configuring Modern XFCE Theme...${NC}"
    echo ""

    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml >> "$INSTALL_LOG" 2>&1

    # GTK Dark Theme
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml << 'XSEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Adwaita-dark"/>
    <property name="IconThemeName" type="string" value="Adwaita"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Sans 10"/>
    <property name="MonospaceFontName" type="string" value="Monospace 10"/>
  </property>
</channel>
XSEOF

    # Terminal Dracula Theme
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-terminal.xml << 'TERMEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-terminal" version="1.0">
  <property name="color-foreground" type="string" value="#f8f8f2"/>
  <property name="color-background" type="string" value="#282a36"/>
  <property name="color-cursor" type="string" value="#f8f8f2"/>
  <property name="color-selection" type="string" value="#44475a"/>
  <property name="color-palette" type="string" value="#21222c;#ff5555;#50fa7b;#f1fa8c;#bd93f9;#ff79c6;#8be9fd;#f8f8f2;#6272a4;#ff6e6e;#69ff94;#ffffa5;#d6acff;#ff92df;#a4ffff;#ffffff"/>
  <property name="font-name" type="string" value="Monospace 11"/>
  <property name="misc-cursor-shape" type="uint" value="1"/>
</channel>
TERMEOF

    # Desktop Icons Cleanup
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml << 'DESKEOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="desktop-icons" type="empty">
    <property name="file-icons" type="empty">
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-removable" type="bool" value="true"/>
    </property>
    <property name="icon-size" type="uint" value="48"/>
  </property>
</channel>
DESKEOF

    echo -e "  ${GREEN}✓${NC} Tema escuro e configurações XFCE aplicadas"
}

# ============== STEP 12: CREATE DESKTOP SHORTCUTS ==============
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

    # VS Code
    cat > ~/Desktop/VSCode.desktop << 'EOF'
[Desktop Entry]
Name=VS Code
Comment=Code Editor
Exec=code-oss --no-sandbox
Icon=code-oss
Type=Application
Categories=Development;
EOF

    # Terminal
    cat > ~/Desktop/Terminal.desktop << 'EOF'
[Desktop Entry]
Name=Terminal
Comment=System Terminal
Exec=xfce4-terminal
Icon=utilities-terminal
Type=Application
Categories=System;TerminalEmulator;
EOF

    chmod +x ~/Desktop/*.desktop 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Desktop shortcuts created"
}

# ============== STEP 13: INSTALL ADDITIONAL APPS ==============
step_additional_apps() {
    if [ ${#SELECTED_APPS[@]} -eq 0 ]; then
        return
    fi

    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Instalando Aplicações Adicionais...${NC}"
    echo ""

    for app in "${SELECTED_APPS[@]}"; do
        if [ "$PROOT_CHOICE" != "0" ]; then
            # Instalação no PRoot
            echo -e "  ${YELLOW}⏳${NC} A instalar ${app} no ${PROOT_LABEL}..."
            
            case $PROOT_DISTRO in
                ubuntu|debian|deepin) CMD="apt-get install -y $app";;
                archlinux|manjaro) CMD="pacman -S --noconfirm $app";;
                fedora) CMD="dnf install -y $app";;
                opensuse) CMD="zypper install -y $app";;
            esac
            
            proot-distro login "$PROOT_DISTRO" -- bash -c "$CMD >> /tmp/install.log 2>&1"
            echo -e "  ${GREEN}✓${NC} ${app} instalado no PRoot"
        else
            # Instalação nativa no Termux
            install_pkg "$app" "$app"
        fi
    done
}

# ============== STEP 14: CLEANUP & OPTIMIZATION ==============
step_cleanup() {
    update_progress
    echo -e "${PURPLE}[Step ${CURRENT_STEP}/${TOTAL_STEPS}] Otimizando Armazenamento...${NC}"
    echo ""

    (pkg clean >> "$INSTALL_LOG" 2>&1) &
    spinner $! "Limpando cache de pacotes Termux..."

    if [ "$PROOT_CHOICE" != "0" ]; then
        case $PROOT_DISTRO in
            ubuntu|debian|deepin) CLEAN_CMD="apt-get clean";;
            archlinux|manjaro) CLEAN_CMD="pacman -Sc --noconfirm";;
            fedora) CLEAN_CMD="dnf clean all";;
            opensuse) CLEAN_CMD="zypper clean -a";;
        esac
        (proot-distro login "$PROOT_DISTRO" -- bash -c "$CLEAN_CMD" >> "$INSTALL_LOG" 2>&1) &
        spinner $! "Limpando cache do ${PROOT_LABEL}..."
    fi
}

# ============== COMPLETION ==============
show_completion() {
    echo ""
    echo -e "${GREEN}"
    cat << 'COMPLETE'

    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║         ✅  INSTALLATION COMPLETE!  ✅                        ║
    ║                                                               ║
    ║              🎉 100% - All Done! 🎉                           ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝

COMPLETE
    echo -e "${NC}"

    echo -e "${WHITE}📱 Your Mobile Linux Desktop is ready!${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}🚀 TO START THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/start-desktop.sh${NC}"
    echo ""
    echo -e "${WHITE}🛑 TO STOP THE DESKTOP:${NC}"
    echo -e "   ${GREEN}bash ~/stop-desktop.sh${NC}"
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${CYAN}📦 INSTALLED TOOLS:${NC}"
    echo -e "   • Firefox, VS Code, Git"
    echo -e "   • ${DESKTOP_NAME} + GPU Acceleration"
    if [ "$PROOT_CHOICE" != "0" ]; then
        echo -e "   • PRoot Integrado: ${PROOT_LABEL} (App Bridge Ativo)"
        echo -e "   • Acesso ao Terminal Linux: bash ~/start-proot.sh"
    fi
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  📺 Subscribe: https://youtube.com/@TechJarves${NC}"
    echo -e "${CYAN}  🎬 Tutorial:  [YOUR VIDEO URL]${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}⚡ TIP: Open Termux-X11 app first, then run start-desktop.sh${NC}"
    echo ""
}

# ============== MAIN INSTALLATION ==============
main() {
    choose_desktop
    choose_proot_distro

    echo -e "${WHITE}  This script will install a complete Linux desktop with${NC}"
    echo -e "${WHITE}  GPU acceleration on your Android phone.${NC}"
    echo ""
    echo -e "${GRAY}  Estimated time: 5-15 minutes (depends on internet speed)${NC}"
    echo ""
    echo -e "${YELLOW}  Press Enter to start installation, or Ctrl+C to cancel...${NC}"
    read

    # Run all steps
    detect_device
    step_update
    step_repos
    step_x11
    step_desktop
    step_gpu
    step_audio
    step_apps
    step_proot
    step_proot_bridge
    step_launchers
    step_theme
    step_shortcuts

    # Show completion
    show_completion
}

# ============== RUN ==============
main
