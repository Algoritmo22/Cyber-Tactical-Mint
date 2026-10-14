#!/bin/bash

# ==============================================================================
# 🛡️ CYBER-TACTICAL-MINT - Ultimate Pentesting & Visual Optimization Script
# Autor: Algoritmo22 / Optimizado para Operaciones de Pentesting
# Descripción: Automatiza la instalación de herramientas de auditoría, optimiza
#              el rendimiento del sistema y despliega una estética táctica/dark.
# ==============================================================================

# Colores para salida en terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# Verificar privilegios de root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Por favor, ejecuta este script con privilegios de administrador (sudo ./cyber-tactical-mint.sh).${NC}"
    exit 1
fi

clear
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════════════════════╗"
echo "║             CYBER-TACTICAL-MINT - SETUP & OPTIMIZATION               ║"
echo "║                 Entorno Táctico para Pentesters                      ║"
echo "╚══════════════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${CYAN}[*] Actualizando repositorios y preparando el sistema...${NC}"
apt update && apt upgrade -y

# 1. INSTALACIÓN DE HERRAMIENTAS ESENCIALES DE PENTESTING Y REDES
echo -e "\n${YELLOW}[+] Instalando suite de herramientas de auditoría y pentesting...${NC}"
apt install -y \
    nmap \
    wireshark \
    tcpdump \
    aircrack-ng \
    hashcat \
    john \
    sqlmap \
    hydra \
    dirb \
    gobuster \
    nikto \
    netcat-traditional \
    tmux \
    htop \
    git \
    curl \
    wget \
    build-essential \
    python3-pip \
    python3-venv \
    macchanger \
    dnsenum \
    whois \
    seclists

# Configurar Wireshark para usuarios sin root de forma segura
echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
dpkg-reconfigure -f noninteractive wireshark-common
usermod -aG wireshark $SUDO_USER

# 2. INSTALACIÓN DE HERRAMIENTAS ADICIONALES (Wifite2 y utilidades avanzadas)
echo -e "\n${YELLOW}[+] Configurando herramientas inalámbricas avanzadas (Wifite2)...${NC}"
if [ ! -d "/opt/wifite2" ]; then
    git clone https://github.com/derv82/wifite2.git /opt/wifite2
    cd /opt/wifite2 && python3 setup.py install
    cd -
fi

# 3. OPTIMIZACIÓN DEL RENDIMIENTO DEL SISTEMA
echo -e "\n${CYAN}[*] Aplicando ajustes de optimización de rendimiento...${NC}"
# Deshabilitar servicios innecesarios en arranque para liberar RAM y CPU
systemctl disable bluetooth.service 2>/dev/null || true

# Configurar Swappiness a un valor óptimo para multitarea pesada (ej. máquinas virtuales)
if ! grep -Fxq "vm.swappiness=10" /etc/sysctl.conf; then
    echo "vm.swappiness=10" >> /etc/sysctl.conf
    sysctl -p
fi

# 4. MEJORA VISUAL TÁCTICA (Tema Dark, Iconos y Fuentes)
echo -e "\n${GREEN}[+] Aplicando personalización visual táctica (Tema Dark / Militar)...${NC}"

# Crear directorios de temas si no existen
USER_HOME=$(eval echo ~$SUDO_USER)
sudo -u $SUDO_USER mkdir -p "$USER_HOME/.themes"
sudo -u $SUDO_USER mkdir -p "$USER_HOME/.icons"
sudo -u $SUDO_USER mkdir -p "$USER_HOME/.fonts"

# Instalar fuentes de programación y terminal (JetBrainsMono / Hack Nerd Fonts)
echo -e "${CYAN}[*] Instalando fuentes tipográficas Nerd Fonts...${NC}"
FONT_DIR="$USER_HOME/.local/share/fonts"
sudo -u $SUDO_USER mkdir -p "$FONT_DIR"
wget -qO /tmp/JetBrainsMono.zip https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
sudo -u $SUDO_USER unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR" >/dev/null
sudo -u $SUDO_USER fc-cache -f -v >/dev/null

# Configurar apariencia básica de la terminal para look táctico (Bashrc personalizado)
BASHRC_PATH="$USER_HOME/.bashrc"
if ! grep -q "CYBER-TACTICAL PROMPT" "$BASHRC_PATH"; then
    cat << 'EOF' >> "$BASHRC_PATH"

# --- CYBER-TACTICAL PROMPT CONFIG ---
export PS1="\[\033[01;32m\]┌──[\[\033[01;31m\]\u@cyber-mint\[\033[01;32m\]]-[\[\033[01;34m\]\w\[\033[01;32m\]]\n\[\033[01;32m\]└──╼ \[\033[01;37m\]\$ \[\033[00m\]"
alias update-tools='sudo apt update && sudo apt upgrade -y'
alias nmap-quick='nmap -T4 -F'
alias myip='ip a | grep inet'
# ------------------------------------
EOF
    chown $SUDO_USER:$SUDO_USER "$BASHRC_PATH"
fi

echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════════════╗"
echo -e "║             ¡CONFIGURACIÓN TÁCTICA COMPLETADA CON ÉXITO!              ║"
echo -e "╚══════════════════════════════════════════════════════════════════════╝${NC}"
echo -e "${YELLOW}[!] Recomendación: Reinicia tu sesión o equipo para aplicar todos los cambios visuales y de grupos.${NC}"
