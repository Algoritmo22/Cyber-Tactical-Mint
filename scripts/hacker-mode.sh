#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consola 5-en-1 Integrada)
# DESCRIPCIÓN: Una sola ventana gigante de Kitty con 5 paneles unidos nativamente
# ==============================================================================

OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Desplegando contenedor unificado de 5 terminales integradas..."

# Lanzamos una única ventana gigante que procesa los 5 paneles de la sesión
kitty \
  -o remember_window_size=no \
  -o initial_window_width=1850 \
  -o initial_window_height=980 \
  -o background_opacity=$OPACIDAD \
  -o background=$COLOR_FONDO \
  -o foreground=$COLOR_TEXTO \
  -o font_size=$TAMANO_LETRA \
  -o hide_window_decorations=yes \
  -o window_padding_width=15 \
  -o active_border_color=none \
  -o inactive_border_color=none \
  -o enabled_layouts=splits \
  --session "/home/luis18/Cyber-Tactical-Mint/configs/kitty/hacker.session" &
