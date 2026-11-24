#!/usr/bin/env bash
# shellcheck shell=bash
# ─────────────────────────────────────────────────────────────────────────────
#  Cyber-Tactical-Mint · funciones compartidas
#  Este archivo se carga con `source`; no se ejecuta directamente.
# ─────────────────────────────────────────────────────────────────────────────

CTM_MARKER="Managed by Cyber-Tactical-Mint"

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/cyber-tactical-mint"
ORIG_DIR="$STATE_DIR/original"      # copia de los archivos que existían antes
ABSENT_DIR="$STATE_DIR/absent"      # marcas de archivos que NO existían antes
MANIFEST="$STATE_DIR/installed.list"
GSET_BAK="$STATE_DIR/settings.bak"

DRY_RUN="${DRY_RUN:-0}"

# ── Mensajes ─────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RST=$'\033[0m'; C_GRN=$'\033[38;2;0;255;156m'; C_CYN=$'\033[38;2;0;229;255m'
  C_YLW=$'\033[38;2;255;179;0m'; C_RED=$'\033[38;2;255;59;59m'; C_DIM=$'\033[2m'
else
  C_RST=""; C_GRN=""; C_CYN=""; C_YLW=""; C_RED=""; C_DIM=""
fi

info() { printf '%s▸%s %s\n' "$C_CYN" "$C_RST" "$*"; }
ok()   { printf '%s✔%s %s\n' "$C_GRN" "$C_RST" "$*"; }
warn() { printf '%s⚠%s %s\n' "$C_YLW" "$C_RST" "$*" >&2; }
die()  { printf '%s✖%s %s\n' "$C_RED" "$C_RST" "$*" >&2; exit 1; }
step() { printf '\n%s━━ %s%s\n' "$C_GRN" "$*" "$C_RST"; }

# Ejecuta un comando, o solo lo muestra si estamos en --dry-run.
run() {
  if (( DRY_RUN )); then
    printf '  %s[dry-run]%s %s\n' "$C_DIM" "$C_RST" "$*"
  else
    "$@"
  fi
}

have() { command -v "$1" >/dev/null 2>&1; }

# ── Estado y manifiesto ──────────────────────────────────────────────────────
ensure_state() {
  (( DRY_RUN )) && return 0
  mkdir -p "$STATE_DIR" "$ORIG_DIR" "$ABSENT_DIR"
  touch "$MANIFEST"
}

manifest_add() {
  (( DRY_RUN )) && return 0
  grep -qxF -- "$1" "$MANIFEST" 2>/dev/null || printf '%s\n' "$1" >> "$MANIFEST"
}

# Guarda el original de un archivo la PRIMERA vez que lo vamos a tocar.
backup_file() {
  local target=$1 rel
  rel=${target#"$HOME"/}
  if [[ ! -e $target && ! -L $target ]]; then
    # No existía: lo anotamos para poder borrarlo al desinstalar.
    if [[ ! -e $ORIG_DIR/$rel && ! -e $ABSENT_DIR/$rel ]]; then
      mkdir -p "$(dirname "$ABSENT_DIR/$rel")"
      : > "$ABSENT_DIR/$rel"
    fi
    return 0
  fi
  [[ -e $ABSENT_DIR/$rel ]] && return 0      # lo creamos nosotros antes
  [[ -e $ORIG_DIR/$rel ]] && return 0        # ya hay un original guardado
  if [[ -f $target ]] && grep -qs -- "$CTM_MARKER" "$target"; then
    return 0                                  # es un archivo nuestro
  fi
  mkdir -p "$(dirname "$ORIG_DIR/$rel")"
  cp -a "$target" "$ORIG_DIR/$rel"
}

# ── Paletas y plantillas ─────────────────────────────────────────────────────
declare -a SED_ARGS=()
declare -A BLOCKS=()
PALETTE_KEYS=(BG BG_ALT FG PRIMARY SECONDARY ACCENT WARN DANGER MUTED)

hex_to_dec() {  # 00ff9c -> "0 255 156"
  printf '%d %d %d' "0x${1:0:2}" "0x${1:2:2}" "0x${1:4:2}"
}

sed_escape() { printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'; }

tpl_set() {  # tpl_set CLAVE valor  → reemplaza @@CLAVE@@ en las plantillas
  SED_ARGS+=(-e "s|@@$1@@|$(sed_escape "$2")|g")
}

load_palette() {
  local name=$1 file="$ROOT_DIR/palettes/$1.sh" key var val r g b
  [[ -f $file ]] || die "Paleta desconocida: '$name'. Disponibles: $(list_palettes | tr '\n' ' ')"
  # shellcheck source=/dev/null
  source "$file"
  SED_ARGS=()
  for key in "${PALETTE_KEYS[@]}"; do
    var="P_$key"; val="${!var}"
    read -r r g b <<< "$(hex_to_dec "$val")"
    tpl_set "$key" "$val"
    tpl_set "${key}_RGB" "$r;$g;$b"
    tpl_set "${key}_R" "$r"
    tpl_set "${key}_G" "$g"
    tpl_set "${key}_B" "$b"
  done
}

list_palettes() {
  local f
  for f in "$ROOT_DIR"/palettes/*.sh; do basename "$f" .sh; done
}

# Renderiza una plantilla a stdout: variables @@X@@ y bloques opcionales.
render_template() {
  local src=$1 text name
  text=$(sed "${SED_ARGS[@]}" "$src")
  for name in "${!BLOCKS[@]}"; do
    text=$(printf '%s\n' "$text" | BLK="${BLOCKS[$name]}" awk -v tok="@@${name}@@" '
      $0 == tok { if (ENVIRON["BLK"] != "") print ENVIRON["BLK"]; next }
      { print }')
  done
  printf '%s\n' "$text"
}

# Instala una plantilla renderizada en `target`.
install_rendered() {
  local src=$1 target=$2 mode=${3:-644} tmp
  if (( DRY_RUN )); then
    printf '  %s[dry-run]%s render %s → %s\n' "$C_DIM" "$C_RST" "${src#"$ROOT_DIR"/}" "$target"
    return 0
  fi
  backup_file "$target"
  mkdir -p "$(dirname "$target")"
  tmp=$(mktemp "${target}.XXXXXX")
  render_template "$src" > "$tmp"
  chmod "$mode" "$tmp"
  mv -f "$tmp" "$target"
  manifest_add "$target"
}

# Copia un archivo tal cual.
install_plain() {
  local src=$1 target=$2 mode=${3:-644}
  if (( DRY_RUN )); then
    printf '  %s[dry-run]%s copy   %s → %s\n' "$C_DIM" "$C_RST" "${src#"$ROOT_DIR"/}" "$target"
    return 0
  fi
  backup_file "$target"
  mkdir -p "$(dirname "$target")"
  install -m "$mode" "$src" "$target"
  manifest_add "$target"
}

# ── Detección de hardware ────────────────────────────────────────────────────
detect_net_iface() {
  local iface=""
  if have ip; then
    iface=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')
  fi
  if [[ -z $iface ]]; then
    local d
    for d in /sys/class/net/*; do
      [[ $(basename "$d") == lo ]] && continue
      iface=$(basename "$d"); break
    done
  fi
  printf '%s' "${iface:-eth0}"
}

has_nvidia() { have nvidia-smi && nvidia-smi -L >/dev/null 2>&1; }

detect_battery() {
  local d
  for d in /sys/class/power_supply/BAT*; do
    [[ -e $d ]] && { basename "$d"; return 0; }
  done
  return 1
}

# ── Ajustes de escritorio (gsettings / dconf) con copia de seguridad ─────────
settings_save() {  # settings_save <tipo> <clave> <valor-actual>
  (( DRY_RUN )) && return 0
  mkdir -p "$STATE_DIR"
  touch "$GSET_BAK"
  grep -qsF -- "$1"$'\t'"$2"$'\t' "$GSET_BAK" && return 0   # conservamos el primero
  printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$GSET_BAK"
}

gs_set() {  # gs_set <schema> <clave> <valor GVariant, p. ej. "'Mint-Y'">
  have gsettings || return 0
  gsettings writable "$1" "$2" >/dev/null 2>&1 || return 0
  settings_save "gs:$1" "$2" "$(gsettings get "$1" "$2" 2>/dev/null)"
  run gsettings set "$1" "$2" "$3" || warn "No pude aplicar $1 $2"
}

dconf_set() {  # dconf_set <ruta> <valor>
  have dconf || return 0
  local old
  old=$(dconf read "$1" 2>/dev/null || true)
  settings_save "dconf" "$1" "${old:-__UNSET__}"
  run dconf write "$1" "$2" || warn "No pude aplicar $1"
}

settings_restore() {
  [[ -f $GSET_BAK ]] || return 0
  local kind key val schema
  while IFS=$'\t' read -r kind key val; do
    [[ -z $kind ]] && continue
    case $kind in
      gs:*)
        schema=${kind#gs:}
        have gsettings && run gsettings set "$schema" "$key" "$val" || true ;;
      dconf)
        have dconf || continue
        if [[ $val == __UNSET__ ]]; then run dconf reset "$key"; else run dconf write "$key" "$val"; fi ;;
    esac
  done < "$GSET_BAK"
}

# ── Bloque en ~/.bashrc ──────────────────────────────────────────────────────
BASHRC="$HOME/.bashrc"
BASHRC_BEGIN="# >>> Cyber-Tactical-Mint >>>"
BASHRC_END="# <<< Cyber-Tactical-Mint <<<"

bashrc_enable() {
  local snippet=$1
  if (( DRY_RUN )); then info "añadiría el bloque de Cyber-Tactical-Mint a ~/.bashrc"; return 0; fi
  touch "$BASHRC"
  [[ -f $STATE_DIR/bashrc.backup ]] || cp -a "$BASHRC" "$STATE_DIR/bashrc.backup"
  bashrc_disable quiet
  {
    printf '\n%s\n' "$BASHRC_BEGIN"
    printf '[ -f "%s" ] && . "%s"\n' "$snippet" "$snippet"
    printf '%s\n' "$BASHRC_END"
  } >> "$BASHRC"
}

bashrc_disable() {
  [[ -f $BASHRC ]] || return 0
  grep -qF -- "$BASHRC_BEGIN" "$BASHRC" || return 0
  if (( DRY_RUN )); then info "quitaría el bloque de Cyber-Tactical-Mint de ~/.bashrc"; return 0; fi
  sed -i "/^${BASHRC_BEGIN//\//\\/}\$/,/^${BASHRC_END//\//\\/}\$/d" "$BASHRC"
  [[ ${1:-} == quiet ]] || ok "Bloque eliminado de ~/.bashrc"
}
