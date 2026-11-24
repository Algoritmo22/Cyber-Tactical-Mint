#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Cyber-Tactical-Mint · desinstalador
#  Restaura los archivos originales que se respaldaron y elimina los que se
#  crearon. No desinstala paquetes de apt.
#
#  Uso:  ./scripts/uninstall.sh [--dry-run] [--purge]
#        --purge  borra también el estado y las copias de seguridad
# ─────────────────────────────────────────────────────────────────────────────
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/scripts/lib/common.sh"

PURGE=0
for arg in "$@"; do
  case $arg in
    -n|--dry-run) DRY_RUN=1 ;;
    --purge)      PURGE=1 ;;
    -h|--help)    sed -n "2,9p" "${BASH_SOURCE[0]}"; exit 0 ;;
    *) die "Opción desconocida: $arg" ;;
  esac
done

[[ $EUID -eq 0 && -z ${CTM_ALLOW_ROOT:-} ]] && die "No ejecutes este script con sudo."
[[ -f $MANIFEST ]] || die "No encuentro una instalación previa ($MANIFEST)."

printf "\n%s⚡ Desinstalando Cyber-Tactical-Mint ⚡%s\n" "$C_GRN" "$C_RST"
(( DRY_RUN )) && warn "Modo --dry-run: no se modificará nada."

step "Deteniendo procesos"
run pkill -x conky || true

step "Restaurando archivos"
while IFS= read -r target; do
  [[ -z $target ]] && continue
  rel=${target#"$HOME"/}
  if [[ -e $ORIG_DIR/$rel ]]; then
    info "restaurar  $target"
    if (( ! DRY_RUN )); then mkdir -p "$(dirname "$target")"; cp -a "$ORIG_DIR/$rel" "$target"; fi
  else
    info "eliminar   $target"
    run rm -f "$target"
  fi
done < "$MANIFEST"

step "Ajustes de escritorio"
settings_restore

step "Shell y fuentes"
bashrc_disable
run rm -rf "$HOME/.local/share/fonts/CyberTacticalMint"
run rm -rf "$HOME/.local/share/backgrounds/cyber-tactical-mint"
run rm -rf "$HOME/.local/share/plank/themes/CyberTactical"
have fc-cache && run fc-cache -f >/dev/null 2>&1 || true

# Quita carpetas vacías que dejamos
for d in "$HOME/.config/conky/cyber-tactical" "$HOME/.config/conky" "$HOME/.config/cyber-tactical-mint" \
         "$HOME/.config/btop/themes" "$HOME/.config/fastfetch"; do
  (( DRY_RUN )) || rmdir "$d" 2>/dev/null || true
done

if (( PURGE )); then
  run rm -rf "$STATE_DIR"
  ok "Estado y copias de seguridad eliminados."
else
  (( DRY_RUN )) || rm -f "$MANIFEST" "$GSET_BAK"
  info "Copias de seguridad conservadas en $ORIG_DIR (usa --purge para borrarlas)."
fi

printf "\n%s✔ Desinstalación completa.%s Cierra sesión o reinicia Plank para ver todos los cambios.\n\n" "$C_GRN" "$C_RST"
