#!/usr/bin/env bash
# Cyber-Tactical-Mint — Centro de Seguridad
# Instalación modular para Linux Mint/Ubuntu. No ejecuta pruebas ofensivas automáticamente.
set -Eeuo pipefail
IFS=$'\n\t'

APP="Cyber-Tactical-Mint Security Center"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/cyber-tactical-mint"
LOG="$STATE_DIR/security-center.log"
mkdir -p "$STATE_DIR"
touch "$LOG"

GREEN=$'\033[1;32m'; CYAN=$'\033[1;36m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; RESET=$'\033[0m'
say(){ printf '%s\n' "$*"; }
log(){ printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG"; }
has(){ command -v "$1" >/dev/null 2>&1; }

if [[ $EUID -eq 0 ]]; then
  printf '%sNo ejecutes este menú con sudo. Solo se solicitará sudo al instalar paquetes.%s\n' "$RED" "$RESET"
  exit 1
fi
if ! command -v apt-get >/dev/null || ! grep -qiE 'Linux Mint|Ubuntu' /etc/os-release; then
  say "Este instalador está diseñado para Linux Mint/Ubuntu con APT."
  exit 1
fi

banner(){
  clear 2>/dev/null || true
  printf '%s' "$CYAN"
  cat <<'EOF'
   ____      __                 ______           __  _
  / ___|    / /_  ____  _______/ ____/___ ______/ /_(_)____
  \__ \   / __ \/ __ \/ ___/ / /   / __ `/ ___/ __/ / ___/
 ___/ /  / /_/ / /_/ (__  ) / /___/ /_/ / /__/ /_/ / /
/____/  /_.___/\____/____/  \____/\__,_/\___/\__/_/_/
             SECURITY OPERATIONS CENTER
EOF
  printf '%s\n' "$RESET"
  say "Linux Mint Cinnamon · módulos bajo demanda · registro: $LOG"
}
install_module(){
  local title="$1"; shift
  local -a packages=("$@")
  log "Preparando módulo: $title"
  printf '%s\n' "$YELLOW$APP: $title$RESET"
  printf 'Paquetes: %s\n' "${packages[*]}"
  read -r -p "¿Instalar este módulo con APT? [s/N] " answer
  [[ "$answer" =~ ^[sS]$ ]] || { log "Cancelado: $title"; return 0; }
  sudo -v
  if sudo apt-get update && sudo apt-get install --no-install-recommends -y "${packages[@]}" 2>&1 | tee -a "$LOG"; then
    log "Instalación finalizada: $title"
  else
    log "ERROR instalando módulo: $title"
    return 1
  fi
}
module_base(){ install_module "Base y diagnóstico" git curl wget jq whois dnsutils traceroute net-tools btop fastfetch kitty tmux python3-venv pipx; }
module_network(){ install_module "Diagnóstico de red" nmap tcpdump wireshark tshark netcat-openbsd socat mtr-tiny arp-scan; }
module_web(){ install_module "Auditoría web autorizada" nikto sqlmap gobuster whatweb; }
module_defense(){ install_module "Defensa y hardening" lynis fail2ban ufw clamav clamav-daemon yara rkhunter; }
module_forensics(){ install_module "Análisis forense" sleuthkit testdisk foremost binwalk radare2 gdb file libimage-exiftool-perl; }

status(){
  banner
  say "${GREEN}=== Estado del sistema ===${RESET}"
  printf 'Distribución: '; . /etc/os-release; printf '%s %s\n' "${PRETTY_NAME:-desconocida}" "${VERSION_ID:-}"
  printf 'Kernel: '; uname -r
  printf 'CPU: '; (lscpu 2>/dev/null | awk -F: '/Model name/{gsub(/^[ \t]+/,"",$2); print $2; exit}') || true
  printf 'Espacio raíz: '; df -h / | awk 'NR==2{print $4 " libres de " $2}'
  printf '\nInterfaces y direcciones:\n'; ip -brief address 2>/dev/null || true
  printf '\nServicios de firewall:\n'
  if has ufw; then ufw status 2>&1 || true; else say "UFW no está instalado."; fi
  printf '\nÚltimas líneas del registro:\n'; tail -n 8 "$LOG" || true
  read -r -p "Pulsa Intro para continuar..." _
}
network_discovery(){
  banner
  say "Descubrimiento de hosts: úsalo solo en redes propias o con autorización explícita."
  read -r -p "Introduce el rango CIDR autorizado (ej. 192.168.1.0/24): " cidr
  [[ "$cidr" =~ ^[0-9a-fA-F:.]+/[0-9]{1,3}$ ]] || { say "Formato CIDR no válido."; read -r -p "Intro..." _; return; }
  has nmap || { say "Nmap no está instalado. Instala primero el módulo de red."; read -r -p "Intro..." _; return; }
  read -r -p "Confirmas que tienes autorización para escanear $cidr? [s/N] " confirm
  [[ "$confirm" =~ ^[sS]$ ]] || { say "Cancelado."; return; }
  log "Inicio de descubrimiento autorizado para $cidr"
  nmap -sn "$cidr" 2>&1 | tee -a "$LOG"
  log "Finalizado descubrimiento para $cidr"
  read -r -p "Pulsa Intro para continuar..." _
}
launch_tool(){
  local tool="$1"
  if has "$tool"; then log "Lanzando $tool"; "$tool" || true
  else say "$tool no está instalado. Instala el módulo correspondiente."; read -r -p "Intro..." _; fi
}
while true; do
  banner
  printf '%s\n' " 1) Instalar módulo base" " 2) Herramientas de red" " 3) Auditoría web autorizada" " 4) Defensa y hardening" " 5) Análisis forense" " 6) Estado del sistema" " 7) Descubrimiento de red autorizado" " 8) Abrir btop" " 9) Abrir Wireshark" "10) Abrir terminal Kitty" " 0) Salir"
  read -r -p "Selecciona una opción: " choice
  case "$choice" in
    1) module_base;; 2) module_network;; 3) module_web;; 4) module_defense;; 5) module_forensics;;
    6) status;; 7) network_discovery;; 8) launch_tool btop;; 9) launch_tool wireshark;; 10) launch_tool kitty;; 0) exit 0;;
    *) say "Opción no válida."; sleep 1;;
  esac
done
