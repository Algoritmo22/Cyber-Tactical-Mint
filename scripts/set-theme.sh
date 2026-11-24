#!/usr/bin/env bash
# Cambia la paleta de todo el entorno. Uso: ./scripts/set-theme.sh <cyber|military|amber>
# shellcheck disable=SC2154  # las variables P_* vienen de palettes/*.sh
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/scripts/lib/common.sh"

if [[ ${1:-} == "" || ${1:-} == -h || ${1:-} == --help ]]; then
  echo "Uso: set-theme.sh <paleta> [opciones de install.sh]"
  echo "Paletas disponibles:"
  for p in $(list_palettes); do
    # shellcheck source=/dev/null
    ( source "$ROOT_DIR/palettes/$p.sh"; printf "  %-10s %s\n" "$P_NAME" "$P_DESC" )
  done
  exit 0
fi
theme=$1; shift
exec "$ROOT_DIR/scripts/install.sh" --theme "$theme" --skip-deps --skip-fonts "$@"
