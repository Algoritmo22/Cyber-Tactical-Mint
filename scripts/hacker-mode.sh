#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consola Cuádruple Integrada)
# DESCRIPCIÓN: Una sola ventana gigante de Kitty con 4 terminales nativas en cuadrícula
# ==============================================================================

# --- PARÁMETROS QUE EMULAN TU PANEL DE LINUX MINT ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Desplegando contenedor unificado de 4 terminales para pentesting..."

# Lanzamos una sola ventana gigante de Kitty.
# El truco está en "enabled_layouts grid", que fuerza a las subventanas a ordenarse en 4 esquinas.
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
  -o enabled_layouts=grid \
  sh -c "
    kitty @ launch --location=after --copy-env sh -c 'echo \"🛰️  1. MONITOREO DE REDES Y LOGS\n---------------------------------\"; exec bash';
    kitty @ launch --location=after --copy-env sh -c 'echo \"⚡ 2. CONSOLA DE ATAQUES / NMAP\n---------------------------------\"; exec bash';
    kitty @ launch --location=after --copy-env sh -c 'echo \"📂 3. SCRIPTS DE PYTHON / UTILS\n---------------------------------\"; exec bash';
    kitty @ launch --location=after --copy-env sh -c 'echo \"🛡️  4. CONSOLA TÁCTICA LIBRE\n---------------------------------\"; exec bash';
    kitty @ close-window --match=id:0
  " &
