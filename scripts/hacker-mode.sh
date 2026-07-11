#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Modo Hacker - Ventanas Distribuidas)
# DESCRIPCIÓN: Abre terminales en tamaños y posiciones exactas para evitar amontonamiento
# ==============================================================================

# --- PARÁMETROS ESTÉTICOS DE TU BARRA DE ESTADO ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Desplegando ventanas tácticas organizadas..."

# 1. Ventana Grande (Izquierda): Monitor de Procesos btop
# --remember-window-size=no permite forzar el tamaño personalizado
kitty \
  -o background_opacity=$OPACIDAD \
  -o font_size=$TAMANO_LETRA \
  -o background=$COLOR_FONDO \
  -o foreground=$COLOR_TEXTO \
  --remember-window-size=no \
  --initial-window-width=1000 \
  --initial-window-height=950 \
  --title "🛰️ TELEMETRÍA DE PROCESOS" \
  -e btop &

sleep 0.4

# 2. Ventana Superior Derecha: Estado del Sistema (Fastfetch)
# Colocada al lado de la ventana de btop
kitty \
  -o background_opacity=$OPACIDAD \
  -o font_size=$TAMANO_LETRA \
  -o background=$COLOR_FONDO \
  -o foreground=$COLOR_TEXTO \
  --remember-window-size=no \
  --initial-window-width=850 \
  --initial-window-height=450 \
  --title "💻 ESTADO DEL SISTEMA" \
  -e sh -c "fastfetch; exec bash" &

sleep 0.4

# 3. Ventana Inferior Derecha: Consola Libre Táctica
# Colocada debajo de la ventana de Fastfetch
kitty \
  -o background_opacity=$OPACIDAD \
  -o font_size=$TAMANO_LETRA \
  -o background=$COLOR_FONDO \
  -o foreground=$COLOR_TEXTO \
  --remember-window-size=no \
  --initial-window-width=850 \
  --initial-window-height=460 \
  --title "⚡ CONSOLA TÁCTICA LIBRE" \
  -e bash &
