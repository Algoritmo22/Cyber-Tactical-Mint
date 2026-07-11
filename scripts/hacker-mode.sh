#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consola Cuádruple con Sesión)
# DESCRIPCIÓN: Carga una cuadrícula perfecta de 4 terminales sin errores de parsing
# ==============================================================================

OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Cargando entorno de pentesting unificado desde archivo de sesión..."

# Ejecutamos Kitty apuntando a nuestra sesión nativa eliminando las opciones problemáticas
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
  --session "/home/luis18/Cyber-Tactical-Mint/configs/kitty/hacker.session" &
