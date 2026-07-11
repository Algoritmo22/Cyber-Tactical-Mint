#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consolas de Pentesting y Monitoreo)
# DESCRIPCIÓN: Tres terminales Kitty vacías y sin marcos para auditorías y redes
# ==============================================================================

# --- AJUSTES DE FUSIÓN CON TU BARRA DE ESTADO ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Desplegando laboratorio de terminales limpias para ciberseguridad..."

# Lanzamos la suite sin decoraciones (botones de cerrar/maximizar ocultos)
# Usamos el diseño nativo de Kitty para dividir el espacio de trabajo.
kitty \
  -o remember_window_size=no \
  -o initial_window_width=1800 \
  -o initial_window_height=950 \
  -o background_opacity=$OPACIDAD \
  -o background=$COLOR_FONDO \
  -o foreground=$COLOR_TEXTO \
  -o font_size=$TAMANO_LETRA \
  -o hide_window_decorations=yes \
  -o window_padding_width=20 \
  -o active_border_color=none \
  -o inactive_border_color=none \
  -o enabled_layouts=splits \
  sh -c "
    kitty @ launch --location=vsplit --copy-env sh -c 'echo \"🛰️  MONITOREO DE REDES Y LOGS\"; exec bash';
    kitty @ launch --location=hsplit --copy-env sh -c 'echo \"⚡ CONSOLA DE AUDITORÍAS / ATAQUE\"; exec bash';
    kitty @ launch --location=hsplit --copy-env sh -c 'echo \"📂 HERRAMIENTAS ADICIONALES\"; exec bash';
    kitty @ close-window --match=id:0
  " &
