#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
#  Cyber-Tactical-Mint · instalador
#  Entorno táctico para Linux Mint (Cinnamon): Conky, Kitty, Btop, Fastfetch,
#  Plank y fondos de pantalla, todo generado desde una sola paleta de colores.
#
#  Uso:  ./scripts/install.sh [opciones]      (NO lo ejecutes con sudo)
# ─────────────────────────────────────────────────────────────────────────────
# shellcheck disable=SC2154  # las variables P_* vienen de palettes/*.sh
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/scripts/lib/common.sh"
VERSION="$(<"$ROOT_DIR/VERSION")"

THEME="cyber"
SKIP_DEPS=0
SKIP_FONTS=0
SKIP_WALLPAPER=0
NO_LAUNCH=0
WITH_EXTRAS=0
WITH_STARSHIP=0
WITH_SYSTEM_THEME=0
FORCE=0

usage() {
  cat <<EOF
Cyber-Tactical-Mint v$VERSION

Uso: ./scripts/install.sh [opciones]

  -t, --theme NOMBRE     Paleta a usar: $(list_palettes | tr '\n' ' ')(por defecto: cyber)
  -n, --dry-run          Muestra qué haría, sin cambiar nada
      --with-extras      Instala también fzf, bat, zoxide y eza (si existen en tus repos)
      --with-starship    Instala el prompt Starship desde starship.rs (opcional)
      --with-system-theme  Aplica tema GTK, iconos y tema de Cinnamon a juego
      --skip-deps        No instala paquetes con apt
      --skip-fonts       No descarga la Nerd Font
      --skip-wallpaper   No cambia el fondo de pantalla
      --no-launch        No inicia/reinicia Conky ni Plank al terminar
      --force            Continúa aunque la distribución no sea Mint/Ubuntu/Debian
  -h, --help             Muestra esta ayuda

Para deshacer todo:  ./scripts/uninstall.sh
EOF
}

while (( $# )); do
  case $1 in
    -t|--theme)          THEME="${2:?Falta el nombre de la paleta}"; shift ;;
    -n|--dry-run)        DRY_RUN=1 ;;
    --with-extras)       WITH_EXTRAS=1 ;;
    --with-starship)     WITH_STARSHIP=1 ;;
    --with-system-theme) WITH_SYSTEM_THEME=1 ;;
    --skip-deps)         SKIP_DEPS=1 ;;
    --skip-fonts)        SKIP_FONTS=1 ;;
    --skip-wallpaper)    SKIP_WALLPAPER=1 ;;
    --no-launch)         NO_LAUNCH=1 ;;
    --force)             FORCE=1 ;;
    -h|--help)           usage; exit 0 ;;
    *) usage >&2; die "Opción desconocida: $1" ;;
  esac
  shift
done

# ── Comprobaciones previas ───────────────────────────────────────────────────
check_system() {
  local id="" like=""
  if [[ -r /etc/os-release ]]; then
    id=$(. /etc/os-release; echo "${ID:-}")
    like=$(. /etc/os-release; echo "${ID_LIKE:-}")
  fi
  case "$id $like" in
    *linuxmint*|*ubuntu*|*debian*) ;;
    *)
      if (( FORCE || DRY_RUN )); then
        warn "Distribución no reconocida (${id:-?}); sigo porque usaste --force/--dry-run."
      else
        die "Este instalador está pensado para Linux Mint/Ubuntu/Debian. Usa --force para continuar igualmente."
      fi ;;
  esac
  [[ ${XDG_CURRENT_DESKTOP:-} == *Cinnamon* ]] \
    || warn "No detecto una sesión Cinnamon; los ajustes de escritorio podrían no aplicarse."
}

if [[ $EUID -eq 0 && -z ${CTM_ALLOW_ROOT:-} ]]; then
  die "No ejecutes este script con sudo. Las configuraciones son de tu usuario; el script pedirá sudo solo para apt. (Contenedores/CI: CTM_ALLOW_ROOT=1)"
fi

printf '\n%s⚡ CYBER-TACTICAL MINT v%s ⚡%s\n' "$C_GRN" "$VERSION" "$C_RST"
(( DRY_RUN )) && warn "Modo --dry-run: no se modificará nada."

check_system
load_palette "$THEME"
info "Paleta: ${P_NAME} — ${P_DESC}"

# ── Paquetes ─────────────────────────────────────────────────────────────────
pkg_candidate() { apt-cache policy "$1" 2>/dev/null | awk '/Candidate:/ {print $2}'; }
pkg_installed() { dpkg -s "$1" >/dev/null 2>&1; }

install_deps() {
  step "Dependencias"
  if ! have apt-get; then
    warn "No hay apt-get; instala a mano: conky kitty btop plank fastfetch."
    return 0
  fi
  local want=(conky-all kitty btop plank fastfetch dconf-cli fontconfig curl unzip)
  (( WITH_EXTRAS )) && want+=(fzf bat zoxide eza)

  local sudo_cmd=()
  have sudo && sudo_cmd=(sudo)
  run "${sudo_cmd[@]}" apt-get update -qq

  local to_install=() missing=() p cand
  for p in "${want[@]}"; do
    pkg_installed "$p" && continue
    cand=$(pkg_candidate "$p")
    if [[ -n $cand && $cand != "(none)" ]]; then to_install+=("$p"); else missing+=("$p"); fi
  done

  if (( ${#to_install[@]} )); then
    info "Instalando: ${to_install[*]}"
    run "${sudo_cmd[@]}" apt-get install -y "${to_install[@]}"
  else
    ok "Todas las dependencias ya están instaladas."
  fi
  if (( ${#missing[@]} )); then
    warn "No disponibles en tus repositorios: ${missing[*]}"
    [[ " ${missing[*]} " == *" fastfetch "* ]] \
      && warn "  fastfetch: descarga el .deb desde https://github.com/fastfetch-cli/fastfetch/releases"
  fi
}

install_fonts() {
  step "Tipografía (JetBrainsMono Nerd Font)"
  if have fc-list && fc-list | grep -qi "JetBrainsMono Nerd Font"; then
    ok "Ya instalada."; return 0
  fi
  if (( SKIP_FONTS )); then warn "Omitida (--skip-fonts)."; return 0; fi
  if (( DRY_RUN )); then
    info "descargaría JetBrainsMono.zip de nerd-fonts a ~/.local/share/fonts/CyberTacticalMint"
    return 0
  fi
  local tmp url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  tmp=$(mktemp -d)
  if curl -fsSL --retry 3 -o "$tmp/font.zip" "$url" && unzip -qo "$tmp/font.zip" '*.ttf' -d "$tmp/ttf"; then
    mkdir -p "$HOME/.local/share/fonts/CyberTacticalMint"
    cp "$tmp"/ttf/*.ttf "$HOME/.local/share/fonts/CyberTacticalMint/"
    fc-cache -f >/dev/null 2>&1 || true
    ok "Fuente instalada."
  else
    warn "No pude descargar la fuente. Se usará una fuente monoespaciada del sistema."
  fi
  rm -rf "$tmp"
}

(( SKIP_DEPS )) || install_deps
install_fonts

# Fuente a usar en las plantillas
FONT_MONO="JetBrainsMono Nerd Font"
if (( SKIP_FONTS )) && have fc-list && ! fc-list | grep -qi "JetBrainsMono Nerd Font"; then
  FONT_MONO="DejaVu Sans Mono"
fi

# ── Detección de hardware ────────────────────────────────────────────────────
step "Detección de hardware"
NET_IFACE="$(detect_net_iface)"
info "Interfaz de red activa: $NET_IFACE"

BATTERY=""
BATTERY="$(detect_battery || true)"

sed_blk() { sed "${SED_ARGS[@]}" "$ROOT_DIR/configs/conky/blocks/$1"; }
tpl_set FONT_MONO "$FONT_MONO"
tpl_set NET_IFACE "$NET_IFACE"
tpl_set BATTERY "${BATTERY:-BAT0}"
tpl_set CTM_HOME "$ROOT_DIR"
tpl_set THEME_NAME "$P_NAME"
tpl_set HOME_DIR "$HOME"
tpl_set CONKY_DIR "${XDG_CONFIG_HOME:-$HOME/.config}/conky/cyber-tactical"
tpl_set CONKY_CONF "${XDG_CONFIG_HOME:-$HOME/.config}/conky/cyber-tactical/conky.conf"

if has_nvidia; then
  info "GPU NVIDIA detectada: se añade su bloque al HUD."
  BLOCKS[GPU_BLOCK]="$(sed_blk gpu.txt)"
else
  info "Sin NVIDIA (o sin nvidia-smi): HUD sin bloque de GPU."
  BLOCKS[GPU_BLOCK]=""
fi
if [[ -n $BATTERY ]]; then
  info "Batería detectada ($BATTERY): se añade al HUD."
  BLOCKS[BATT_BLOCK]="$(sed_blk battery.txt)"
else
  BLOCKS[BATT_BLOCK]=""
fi

# ── Configuraciones ──────────────────────────────────────────────────────────
step "Instalando configuraciones"
ensure_state
(( DRY_RUN )) || printf '%s\n' "$P_NAME" > "$STATE_DIR/theme"

CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"

# Conky
install_rendered "$ROOT_DIR/configs/conky/conky.conf.tpl" "$CFG/conky/cyber-tactical/conky.conf"
install_plain    "$ROOT_DIR/scripts/helpers/cpu-temp.sh"  "$CFG/conky/cyber-tactical/cpu-temp.sh" 755
ok "Conky HUD"

# Kitty
install_rendered "$ROOT_DIR/configs/kitty/kitty.conf.tpl" "$CFG/kitty/kitty.conf"
ok "Kitty"

# Btop
install_rendered "$ROOT_DIR/configs/btop/cyber-tactical.theme.tpl" "$CFG/btop/themes/cyber-tactical.theme"
configure_btop() {
  local conf="$CFG/btop/btop.conf"
  if [[ -f $conf ]]; then
    if (( DRY_RUN )); then info "ajustaría color_theme en $conf"; return 0; fi
    backup_file "$conf"
    for kv in 'color_theme|"cyber-tactical"' 'theme_background|False' 'truecolor|True'; do
      key=${kv%%|*}; val=${kv#*|}
      if grep -q "^${key}[ =]" "$conf"; then
        sed -i "s|^${key}[ =].*|${key} = ${val}|" "$conf"
      else
        printf '%s = %s\n' "$key" "$val" >> "$conf"
      fi
    done
    manifest_add "$conf"
  else
    install_rendered "$ROOT_DIR/configs/btop/btop.conf.tpl" "$conf"
  fi
}
configure_btop
ok "Btop"

# Fastfetch
install_rendered "$ROOT_DIR/configs/fastfetch/config.jsonc.tpl" "$CFG/fastfetch/config.jsonc"
ok "Fastfetch"

# Plank
install_rendered "$ROOT_DIR/configs/plank/dock.theme.tpl" "$DATA/plank/themes/CyberTactical/dock.theme"
PLANK_DOCK="/net/launchpad/plank/docks/dock1"
dconf_set "$PLANK_DOCK/theme"        "'CyberTactical'"
dconf_set "$PLANK_DOCK/icon-size"    "44"
dconf_set "$PLANK_DOCK/hide-mode"    "'window-dodge'"
dconf_set "$PLANK_DOCK/zoom-enabled" "true"
dconf_set "$PLANK_DOCK/zoom-percent" "130"
ok "Plank"

# Starship (opcional)
if (( WITH_STARSHIP )) && ! have starship; then
  step "Starship"
  if (( DRY_RUN )); then
    info "ejecutaría el instalador oficial de https://starship.rs en ~/.local/bin"
  else
    mkdir -p "$HOME/.local/bin"
    curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin" \
      || warn "No se pudo instalar Starship; se usará el prompt integrado."
  fi
fi
if have starship || [[ -x $HOME/.local/bin/starship ]] || (( WITH_STARSHIP && DRY_RUN )); then
  install_rendered "$ROOT_DIR/configs/shell/starship.toml.tpl" "$CFG/starship.toml"
  ok "Starship (configuración)"
fi

# Shell (alias, prompt, atajos)
install_rendered "$ROOT_DIR/configs/shell/shell.sh.tpl" "$CFG/cyber-tactical-mint/shell.sh"
bashrc_enable "$CFG/cyber-tactical-mint/shell.sh"
ok "Shell (alias y prompt) — se activa al abrir una terminal nueva"

# Autostart
AUTOSTART="$CFG/autostart"
install_rendered "$ROOT_DIR/configs/autostart/conky.desktop.tpl" "$AUTOSTART/cyber-tactical-conky.desktop"
install_rendered "$ROOT_DIR/configs/autostart/plank.desktop.tpl" "$AUTOSTART/cyber-tactical-plank.desktop"
ok "Inicio automático de Conky y Plank"

# ── Fondos y ajustes de escritorio ───────────────────────────────────────────
step "Escritorio"
BG_DIR="$DATA/backgrounds/cyber-tactical-mint"
for wp in "$ROOT_DIR"/wallpapers/*.jpg; do
  [[ -e $wp ]] || continue
  install_plain "$wp" "$BG_DIR/$(basename "$wp")"
done
if (( ! SKIP_WALLPAPER )) && [[ -f $ROOT_DIR/wallpapers/$P_NAME.jpg ]]; then
  gs_set org.cinnamon.desktop.background picture-uri "'file://$BG_DIR/$P_NAME.jpg'"
  gs_set org.cinnamon.desktop.background picture-options "'zoom'"
  ok "Fondo de pantalla: $P_NAME"
fi

# Kitty como terminal predeterminada (Ctrl+Alt+T)
gs_set org.cinnamon.desktop.default-applications.terminal exec "'kitty'"
gs_set org.cinnamon.desktop.default-applications.terminal exec-arg "''"
ok "Kitty como terminal predeterminada"

if (( WITH_SYSTEM_THEME )); then
  if [[ -d /usr/share/themes/$P_GTK_THEME ]]; then
    gs_set org.cinnamon.desktop.interface gtk-theme "'$P_GTK_THEME'"
    gs_set org.cinnamon.theme name "'$P_GTK_THEME'"
    ok "Tema GTK/Cinnamon: $P_GTK_THEME"
  else
    warn "El tema '$P_GTK_THEME' no está instalado; se omite."
  fi
  if [[ -d /usr/share/icons/$P_ICON_THEME ]]; then
    gs_set org.cinnamon.desktop.interface icon-theme "'$P_ICON_THEME'"
    ok "Iconos: $P_ICON_THEME"
  else
    warn "Los iconos '$P_ICON_THEME' no están instalados; se omiten."
  fi
fi

# ── Arranque inmediato ───────────────────────────────────────────────────────
if (( ! NO_LAUNCH )) && [[ -n ${DISPLAY:-} ]]; then
  step "Aplicando cambios"
  if have conky; then
    run pkill -x conky || true
    if (( ! DRY_RUN )); then
      sleep 1
      setsid conky -c "$CFG/conky/cyber-tactical/conky.conf" >/dev/null 2>&1 &
    fi
    ok "Conky iniciado"
  fi
  if have plank; then
    run pkill -x plank || true
    if (( ! DRY_RUN )); then
      sleep 1
      setsid plank >/dev/null 2>&1 &
    fi
    ok "Plank iniciado"
  fi
fi

printf '\n%s✔ Listo.%s Paleta activa: %s%s%s\n' "$C_GRN" "$C_RST" "$C_CYN" "$P_NAME" "$C_RST"
cat <<EOF

  • Abre una terminal nueva (Ctrl+Alt+T) para ver Kitty y el prompt.
  • Cambiar de paleta:   ./scripts/set-theme.sh <cyber|military|amber>
  • Deshacer todo:       ./scripts/uninstall.sh
  • Si falta algo:       docs/TROUBLESHOOTING.md

EOF
