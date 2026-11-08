#!/usr/bin/env bash
# Cyber-Tactical-Mint :: instalador
# Uso: ./scripts/install.sh [--dry-run] [--uninstall] [--help]
# Ejecutar como USUARIO NORMAL (no con sudo): el script pide sudo solo para apt.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
BACKUP_ROOT="$HOME/.cyber-tactical-mint-backup"
BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
FONT_DIR="$HOME/.local/share/fonts/NerdFonts"
CONFIGS=(conky kitty btop fastfetch)   # carpetas dentro de configs/ que se instalan

DRY_RUN=0
UNINSTALL=0

log()  { printf '\033[1;36m[+]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[x]\033[0m %s\n' "$*" >&2; exit 1; }

run() {
  if [ "$DRY_RUN" -eq 1 ]; then
    printf '\033[0;90m[dry-run]\033[0m %s\n' "$*"
  else
    "$@"
  fi
}

usage() {
  cat <<EOF
Cyber-Tactical-Mint
  --dry-run     Muestra lo que haría sin modificar nada
  --uninstall   Quita autoarranques y restaura el último respaldo
  --help        Esta ayuda
EOF
}

for arg in "$@"; do
  case "$arg" in
    --dry-run)   DRY_RUN=1 ;;
    --uninstall) UNINSTALL=1 ;;
    --help|-h)   usage; exit 0 ;;
    *) die "Opción desconocida: $arg (usa --help)" ;;
  esac
done

[ "$EUID" -ne 0 ] || die "No ejecutes este script como root ni con sudo. Úsalo como usuario normal."

backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    run mkdir -p "$BACKUP_DIR"
    run cp -a "$target" "$BACKUP_DIR/"
    log "Respaldo de $target -> $BACKUP_DIR"
  fi
}

detect_iface() {
  local iface
  iface="$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')"
  if [ -z "$iface" ]; then
    iface="$(ip -o link show 2>/dev/null | awk -F': ' '$2 != "lo" {print $2; exit}')"
  fi
  printf '%s' "${iface:-eth0}"
}

write_autostart() {
  local name="$1" exec_cmd="$2" file="$CONFIG_HOME/autostart/$1.desktop"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] crear $file"
    return
  fi
  mkdir -p "$CONFIG_HOME/autostart"
  cat > "$file" <<EOF
[Desktop Entry]
Type=Application
Name=$name
Exec=$exec_cmd
X-GNOME-Autostart-enabled=true
EOF
}

# ------------------------------------------------------------------ desinstalar
if [ "$UNINSTALL" -eq 1 ]; then
  log "Desinstalando..."
  run pkill -x conky || true
  run rm -f "$CONFIG_HOME/autostart/cyber-tactical-conky.desktop" \
            "$CONFIG_HOME/autostart/cyber-tactical-plank.desktop"
  latest="$(ls -1d "$BACKUP_ROOT"/*/ 2>/dev/null | sort | tail -n1 || true)"
  if [ -n "$latest" ]; then
    log "Restaurando respaldo: $latest"
    for item in "$latest"*; do
      [ -e "$item" ] || continue
      run rm -rf "$CONFIG_HOME/$(basename "$item")"
      run cp -a "$item" "$CONFIG_HOME/"
    done
  else
    warn "No hay respaldos. Las carpetas instaladas en $CONFIG_HOME se dejan tal cual."
  fi
  log "Listo. Los paquetes instalados con apt no se eliminan."
  exit 0
fi

# ------------------------------------------------------------------ comprobaciones
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  case "${ID:-}${ID_LIKE:-}" in
    *linuxmint*|*ubuntu*|*debian*) ;;
    *) warn "Sistema no probado (${PRETTY_NAME:-desconocido}). Pensado para Linux Mint / Ubuntu / Debian." ;;
  esac
fi
command -v apt-get >/dev/null || die "Se requiere apt-get."

# ------------------------------------------------------------------ paquetes
log "Instalando paquetes (se pedirá sudo)..."
run sudo apt-get update
# conky-all incluye soporte Lua/Cairo, necesario para los relojes
run sudo apt-get install -y conky-all kitty btop plank curl unzip fontconfig lm-sensors

if apt-cache policy fastfetch 2>/dev/null | grep -q 'Candidate: [0-9]'; then
  run sudo apt-get install -y fastfetch
else
  warn "fastfetch no está en tus repositorios. Instálalo manualmente desde su página de releases."
fi

# ------------------------------------------------------------------ fuentes
if fc-list 2>/dev/null | grep -qi 'JetBrainsMono Nerd'; then
  log "Nerd Font ya instalada."
else
  log "Descargando JetBrainsMono Nerd Font..."
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  base="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
  run curl -fsSL -o "$tmp/JetBrainsMono.zip" "$base/JetBrainsMono.zip"
  if [ "$DRY_RUN" -eq 0 ]; then
    if curl -fsSL -o "$tmp/SHA-256.txt" "$base/SHA-256.txt" 2>/dev/null; then
      expected="$(awk '/JetBrainsMono\.zip/ {print $1; exit}' "$tmp/SHA-256.txt")"
      actual="$(sha256sum "$tmp/JetBrainsMono.zip" | awk '{print $1}')"
      [ -n "$expected" ] && [ "$expected" = "$actual" ] || die "Checksum de la fuente inválido. Abortando."
      log "Checksum verificado."
    else
      warn "No se pudo descargar el archivo de checksums; fuente sin verificar."
    fi
  fi
  run mkdir -p "$FONT_DIR"
  run unzip -oq "$tmp/JetBrainsMono.zip" -d "$FONT_DIR"
  run fc-cache -f
fi

# ------------------------------------------------------------------ configuraciones
IFACE="$(detect_iface)"
log "Interfaz de red detectada: $IFACE"

for name in "${CONFIGS[@]}"; do
  src="$REPO_DIR/configs/$name"
  if [ ! -d "$src" ]; then
    warn "configs/$name no existe en el repo, se omite."
    continue
  fi
  backup "$CONFIG_HOME/$name"
  run mkdir -p "$CONFIG_HOME/$name"
  run cp -a "$src/." "$CONFIG_HOME/$name/"
  log "Instalado: $name"
done

# Sustituir marcadores en Conky
if [ -f "$CONFIG_HOME/conky/conky.conf" ] || [ "$DRY_RUN" -eq 1 ]; then
  run sed -i "s|__NET_IFACE__|$IFACE|g; s|__HOME__|$HOME|g" "$CONFIG_HOME/conky/conky.conf"
fi

# Wallpapers
if [ -d "$REPO_DIR/wallpapers" ]; then
  run mkdir -p "$HOME/Pictures/Cyber-Tactical-Mint"
  run cp -a "$REPO_DIR/wallpapers/." "$HOME/Pictures/Cyber-Tactical-Mint/"
fi

# ------------------------------------------------------------------ autoarranque
write_autostart "cyber-tactical-conky" "sh -c 'sleep 5 && conky -c $CONFIG_HOME/conky/conky.conf'"
write_autostart "cyber-tactical-plank" "plank"

log "Instalación completa. Cierra sesión y vuelve a entrar, o prueba ahora con:"
echo "    pkill conky; conky -c $CONFIG_HOME/conky/conky.conf &"
echo "Para revertir:  ./scripts/install.sh --uninstall"
