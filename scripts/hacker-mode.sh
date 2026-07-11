#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consola Cuádruple con Bordes)
# DESCRIPCIÓN: Abre la cuadrícula sin fallos e incluye líneas divisorias
# ==============================================================================

# --- PARÁMETROS QUE EMULAN TU PANEL DE LINUX MINT ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Inicializando laboratorio con cuadrícula y líneas divisorias..."

# Cambiamos active_border_color por un tono cyan para que las líneas divisorias
# se dibujen claramente entre tus 4 esquinas de terminal.
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
  -o draw_minimal_borders=yes \
  -o active_border_color=#00ffff \
  -o inactive_border_color=#49514c \
  --session "/home/luis18/Cyber-Tactical-Mint/configs/kitty/hacker.session" &
