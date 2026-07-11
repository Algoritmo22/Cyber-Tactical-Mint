#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Desinstalador Limpio)
# DESCRIPCIÓN: Revierte los cambios aplicados por el instalador táctico
# ==============================================================================

NEON_ROJO="\e[1;31m"
NEON_CYAN="\e[1;36m"
NEON_AMARILLO="\e[1;33m"
RESET="\e[0m"

clear
echo -e "${NEON_ROJO}=== Iniciando Desinstalación de Cyber-Tactical-Mint ===${RESET}\n"

if [ "$EUID" -ne 0 ]; then
  echo -e "${NEON_ROJO}[!] ERROR: Este script requiere privilegios de Administrador (sudo).${RESET}"
  exit 1
fi

REAL_USER=${SUDO_USER:-$USER}
USER_HOME=$(eval echo ~$REAL_USER)

echo -e "${NEON_CYAN}[*] Deteniendo procesos en ejecución...${RESET}"
killall conky plank picom kitty btop 2>/dev/null

echo -e "${NEON_CYAN}[*] Eliminando archivos de configuración del usuario...${RESET}"
rm -rf "$USER_HOME/.config/conky"
rm -rf "$USER_HOME/.config/kitty"

echo -e "${NEON_CYAN}[*] Eliminando accesos de inicio automático...${RESET}"
rm -f "$USER_HOME/.config/autostart/conky-tactical.desktop"
rm -f "$USER_HOME/.config/autostart/plank-tactical.desktop"

echo -e "${NEON_AMARILLO}[i] ¿Deseas remover los paquetes instalados (kitty, conky-all, plank, picom, btop, fastfetch)? [s/N]: ${RESET}"
read -r RESPUESTA

if [[ "$RESPUESTA" =~ ^[sS]$ ]]; then
    echo -e "${NEON_ROJO}[*] Removiendo paquetes del sistema...${RESET}"
    apt purge -y kitty conky-all plank picom btop fastfetch
    apt autoremove -y
fi

echo -e "\n${NEON_CYAN}[✔] El sistema ha sido restaurado con éxito para el usuario: $REAL_USER.${RESET}\n"
