#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consola 5-en-1 Integrada Estilo Rombo)
# DESCRIPCIÓN: Una sola ventana gigante de Kitty con 5 paneles unidos nativamente
# ==============================================================================

# --- PARÁMETROS QUE EMULAN TU PANEL DE LINUX MINT ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="12.5"

echo "[*] Desplegando estación HUD de 5 terminales integradas..."

# Lanzamos una única ventana gigante que procesa los 5 paneles de la sesión.
# Forzamos los bordes internos a 2 píxeles para encuadrar la unión con la central.
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
  -o window_border_width=2 \
  -o draw_minimal_borders=no \
  -o active_border_color=#00ffff \
  -o inactive_border_color=#49514c \
  -o enabled_layouts=splits \
  --session "/home/luis18/Cyber-Tactical-Mint/configs/kitty/hacker.session" &
