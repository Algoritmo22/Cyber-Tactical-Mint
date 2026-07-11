#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Modo Hacker - Espacio Ampliado V3)
# DESCRIPCIÓN: Abre terminales independientes en proporciones amplias y ordenadas
# ==============================================================================

# --- ATRIBUTOS QUE EMULAN TU BARRA DE ESTADO ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Desplegando suite táctica en proporciones ampliadas..."

# 1. Ventana Gigante (Izquierda): Monitor de Procesos btop
kitty \
  -o remember_window_size=no \
  -o initial_window_width=1000 \
  -o initial_window_height=900 \
  -o background_opacity=$OPACIDAD \
  -o font_size=$TAMANO_LETRA \
  -o background=$COLOR_FONDO \
  -o foreground=$COLOR_TEXTO \
  --title "🛰️ TELEMETRÍA DE PROCESOS" \
  -e btop &

sleep 0.4

# 2. Ventana Superior Derecha: Estado del Sistema (Fastfetch)
kitty \
  -o remember_window_size=no \
  -o initial_window_width=850 \
  -o initial_window_height=420 \
  -o background_opacity=$OPACIDAD \
  -o font_size=$TAMANO_LETRA \
  -o background=$COLOR_FONDO \
  -o foreground=$COLOR_TEXTO \
  --title "💻 ESTADO DEL SISTEMA" \
  -e sh -c "fastfetch; exec bash" &

sleep 0.4

# 3. Ventana Inferior Derecha: Consola Libre Táctica
kitty \
  -o remember_window_size=no \
  -o initial_window_width=850 \
  -o initial_window_height=420 \
  -o background_opacity=$OPACIDAD \
  -o font_size=$TAMANO_LETRA \
  -o background=$COLOR_FONDO \
  -o foreground=$COLOR_TEXTO \
  --title "⚡ CONSOLA TÁCTICA LIBRE" \
  -e bash &
