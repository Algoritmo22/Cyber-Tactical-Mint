#!/usr/bin/env bash
# Actualiza el repositorio y vuelve a aplicar la paleta actual.
set -Eeuo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/scripts/lib/common.sh"

have git || die "Necesitas git para actualizar."
[[ -d $ROOT_DIR/.git ]] || die "Este directorio no es un clon de git; descarga la versión nueva manualmente."

info "Descargando cambios…"
git -C "$ROOT_DIR" pull --ff-only
theme="cyber"
[[ -f $STATE_DIR/theme ]] && theme=$(<"$STATE_DIR/theme")
exec "$ROOT_DIR/scripts/install.sh" --theme "$theme" --skip-deps --skip-fonts "$@"
