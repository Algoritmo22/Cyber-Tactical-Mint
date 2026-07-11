#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consola Cuádruple - Solución de Color)
# DESCRIPCIÓN: Cuadrícula de 4 terminales sin errores de parsing ni color
# ==============================================================================

# --- PARÁMETROS QUE EMULAN TU PANEL DE LINUX MINT ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Desplegando suite táctica con bordes invisibles calibrados..."

# Cambiamos "none" por el código $COLOR_FONDO para que las líneas divisorias
# se pinten del mismo color del fondo y se vuelvan totalmente invisibles.
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
  -o active_border_color=$COLOR_FONDO \
  -o inactive_border_color=$COLOR_FONDO \
  --session "/home/luis18/Cyber-Tactical-Mint/configs/kitty/hacker.session" &
