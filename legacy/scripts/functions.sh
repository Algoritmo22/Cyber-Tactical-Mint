#!/usr/bin/env bash
# ==============================================================================
# Cyber-Tactical-Mint - Core Functions & Environment Variables
# ==============================================================================

# Paleta de Colores HUD (ANSI)
export CLR_RESET="\033[0m"
export CLR_TACTICAL="\033[38;5;46m"   # Verde Matriz/Radar brillante
export CLR_OLIVE="\033[38;5;28m"      # Verde Oliva oscuro para detalles
export CLR_WARN="\033[38;5;214m"     # Naranja de advertencia del sistema
export CLR_CRITICAL="\033[38;5;196m" # Rojo de fallo/alerta crítica
export CLR_INFO="\033[38;5;39m"       # Azul de información táctica

# Marcas de estado (Banners de Consola)
TAG_OK="[  ${CLR_TACTICAL}OK${CLR_RESET}  ]"
TAG_FAIL="[ ${CLR_CRITICAL}FAIL${CLR_RESET} ]"
TAG_WARN="[ ${CLR_WARN}WARN${CLR_RESET} ]"
TAG_INFO="[ ${CLR_INFO}INFO${CLR_RESET} ]"

log_info() {
    echo -e "${TAG_INFO} $1"
}

log_success() {
    echo -e "${TAG_OK} $1"
}

log_warning() {
    echo -e "${TAG_WARN} $1"
}

log_error() {
    echo -e "${TAG_FAIL} ${CLR_CRITICAL}$1${CLR_RESET}" >&2
}

check_not_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "No ejecutes este script como ROOT directo (sudo ./install.sh)."
        log_error "Ejecútalo como usuario normal: ./install.sh"
        exit 1
    fi
}
