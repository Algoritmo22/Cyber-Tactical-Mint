#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consolas de Pentesting Limpias V2)
# DESCRIPCIÓN: Lanza terminales translúcidas independientes y elimina sus marcos
# ==============================================================================

# --- PARÁMETROS QUE EMULAN TU PANEL DE LINUX MINT ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Inicializando laboratorio de pentesting..."

# Función reutilizable para abrir cada terminal limpia
abrir_terminal_tactica() {
    local titulo="$1"
    local texto_inicial="$2"
    
    kitty \
      -o remember_window_size=no \
      -o initial_window_width=850 \
      -o initial_window_height=450 \
      -o background_opacity=$OPACIDAD \
      -o background=$COLOR_FONDO \
      -o foreground=$COLOR_TEXTO \
      -o font_size=$TAMANO_LETRA \
      -o hide_window_decorations=yes \
      -o window_padding_width=20 \
      --title "$titulo" \
      -e sh -c "echo '$texto_inicial'; exec bash" &
}

# 1. Abrir Terminal de Monitoreo
abrir_terminal_tactica "🛰️ MONITOREO DE REDES" "🛰️  MONITOREO DE REDES Y LOGS ACTIVO (wlp4s2)\n--------------------------------------------------"

sleep 0.3

# 2. Abrir Terminal de Ataque
abrir_terminal_tactica "⚡ CONSOLA DE AUDITORÍAS" "⚡ CONSOLA DE AUDITORÍAS / ATAQUE\n--------------------------------------------------"

sleep 0.3

# 3. Abrir Tercera Terminal de Soporte
abrir_terminal_tactica "📂 HERRAMIENTAS" "📂 HERRAMIENTAS ADICIONALES Y GESTIÓN\n--------------------------------------------------"

echo "[✔] Suite táctica desplegada con éxito."
