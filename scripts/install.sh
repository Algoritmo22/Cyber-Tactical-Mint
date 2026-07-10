#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Instalador Inteligente V2)
# DESCRIPCIÓN: Automatización modular para entorno táctico en Linux Mint
# ==============================================================================

# --- COLORES PARA LA TERMINAL ---
NEON_VERDE="\e[1;32m"
NEON_CYAN="\e[1;36m"
NEON_ROJO="\e[1;31m"
NEON_AMARILLO="\e[1;33m"
RESET="\e[0m"

# --- LOGO ---
clear
echo -e "${NEON_CYAN}"
echo "  ██████╗██╗   ██╗██████╗ ███████╗██████╗ "
echo " ██╔════╝╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗"
echo " ██║      ╚████╔╝ ██████╔╝█████╗  ██████╔╝"
echo " ██║       ╚██╔╝  ██╔══██╗██╔══╝  ██╔══██╗"
echo " ╚██████╗   ██║   ██████╔╝███████╗██║  ██║"
echo "  ╚═════╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝"
echo "       T A C T I C A L   M I N T          "
echo -e "${RESET}"

# --- COMPROBACIÓN DE PRIVILEGIOS ---
if [ "$EUID" -ne 0 ]; then
  echo -e "${NEON_ROJO}[!] ERROR: Este script requiere privilegios de Administrador (sudo).${RESET}"
  exit 1
fi

# ==============================================================================
# [BLOQUE B] DETECCIÓN INTELIGENTE DE HARDWARE Y RED
# ==============================================================================
echo -e "${NEON_CYAN}[*] Analizando la arquitectura de tu hardware...${RESET}"

GPU_CHECK=$(lspci | grep -E "VGA|3D" | grep -i -E "nvidia|intel|amd|radeon")
NET_CHECK=$(ip -o -4 route show to default | awk '{print $5}' | head -n1)

HAS_NVIDIA=false
if [[ $GPU_CHECK =~ "NVIDIA" ]]; then
    HAS_NVIDIA=true
    echo -e "${NEON_VERDE}    -> GPU Detectada: NVIDIA${RESET}"
else
    echo -e "${NEON_AMARILLO}    -> GPU Detectada: Intel/AMD (Se omitirá nvidia-smi)${RESET}"
fi
echo -e "${NEON_VERDE}    -> Interfaz de red activa: $NET_CHECK${RESET}\n"

# ==============================================================================
# [BLOQUE A] MENÚ INTERACTIVO MODULAR
# ==============================================================================
echo -e "${NEON_AMARILLO}Selecciona los componentes tácticos que deseas desplegar:${RESET}"
echo -e " 1) ${NEON_CYAN}Instalación Completa${RESET} (Kitty, Conky, Plank, Picom, btop, Fastfetch)"
echo -e " 2) ${NEON_CYAN}Suite de Escritorio${RESET}  (Solo Conky HUD, Fuentes y Dock Plank)"
echo -e " 3) ${NEON_CYAN}Suite de Terminal${RESET}    (Solo Kitty Terminal, btop, Fastfetch)"
echo -e " 4) ${NEON_ROJO}Cancelar e Interrumpir${RESET}"
echo ""
read -p "Introduce el número de tu opción [1-4]: " OPCION

# --- FUNCIONES DE INSTALACIÓN ---
instalar_base() {
    echo -e "\n${NEON_CYAN}[*] Actualizando repositorios del sistema e instalando dependencias comunes...${RESET}"
    apt update && apt install -y git wget curl unzip lm-sensors
}

instalar_terminal_suite() {
    echo -e "\n${NEON_VERDE}[+] Desplegando Suite de Terminal...${RESET}"
    apt install -y kitty btop fastfetch
}

instalar_desktop_suite() {
    echo -e "\n${NEON_VERDE}[+] Desplegando Suite de Escritorio...${RESET}"
    apt install -y conky-all plank picom
    
    # Parcheo en caliente del archivo del autor para corregir errores de hardware
    CONKY_CONF="../configs/conky/cyberpunk-conky.conf" 
    if [ -f "$CONKY_CONF" ]; then
        sed -i "s/wlan0/$NET_CHECK/g" "$CONKY_CONF"
        sed -i "s/eth0/$NET_CHECK/g" "$CONKY_CONF"
        if [ "$HAS_NVIDIA" = false ]; then
            sed -i '/nvidia-smi/s/^/# /' "$CONKY_CONF"
        fi
    fi
}

# ==============================================================================
# [BLOQUE C] DESPLIEGUE DE CONFIGURACIONES, FUENTES E INICIO AUTOMÁTICO
# ==============================================================================
desplegar_recursos_usuario() {
    REAL_USER=${SUDO_USER:-$USER}
    USER_HOME=$(eval echo ~$REAL_USER)

    echo -e "\n${NEON_CYAN}[*] Desplegando archivos de configuración para el usuario: $REAL_USER...${RESET}"

    mkdir -p "$USER_HOME/.config/conky"
    mkdir -p "$USER_HOME/.config/autostart"
    mkdir -p "$USER_HOME/.local/share/fonts"

    if [ -f "../configs/conky/cyberpunk-conky.conf" ]; then
        cp "../configs/conky/cyberpunk-conky.conf" "$USER_HOME/.config/conky/"
        echo -e "${NEON_VERDE}    -> Configuración de Conky copiada correctamente.${RESET}"
    fi

    if [ -d "../configs/fonts" ] && [ "$(ls -A ../configs/fonts)" ]; then
        cp ../configs/fonts/*.{ttf,otf} "$USER_HOME/.local/share/fonts/" 2>/dev/null
        sudo -u "$REAL_USER" fc-cache -fv > /dev/null
        echo -e "${NEON_VERDE}    -> Fuentes tácticas instaladas en el sistema.${RESET}"
    fi

    # Crear lanzadores de inicio automático (.desktop)
    cat <<EOF > "$USER_HOME/.config/autostart/conky-tactical.desktop"
[Desktop Entry]
Type=Application
Exec=sh -c "sleep 5 && conky -c $USER_HOME/.config/conky/cyberpunk-conky.conf"
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Conky Cyber-Tactical
Comment=Inicia el monitor HUD táctico al encender el sistema
EOF

    cat <<EOF > "$USER_HOME/.config/autostart/plank-tactical.desktop"
[Desktop Entry]
Type=Application
Exec=plank
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Plank Dock
Comment=Inicia la barra de aplicaciones táctica
EOF

    # Corregir los permisos de propietario
    chown -R "$REAL_USER":"$REAL_USER" "$USER_HOME/.config/conky"
    chown -R "$REAL_USER":"$REAL_USER" "$USER_HOME/.config/autostart"
    chown -R "$REAL_USER":"$REAL_USER" "$USER_HOME/.local/share/fonts"
}

# --- EVALUACIÓN DE MENÚ ---
case $OPCION in
    1)
        instalar_base
        instalar_terminal_suite
        instalar_desktop_suite
        desplegar_recursos_usuario
        ;;
    2)
        instalar_base
        instalar_desktop_suite
        desplegar_recursos_usuario
        ;;
    3)
        instalar_base
        instalar_terminal_suite
        desplegar_recursos_usuario
        ;;
    4|*)
        echo -e "\n${NEON_ROJO}[!] Operación cancelada por el usuario.${RESET}\n"
        exit 0
        ;;
esac

echo -e "\n${NEON_VERDE}=== Sistema Cyber-Tactical-Mint Desplegado Correctamente ===${RESET}"
echo -e "${NEON_AMARILLO}[i] Te recomendamos reiniciar el sistema para aplicar la personalización.${RESET}\n"
