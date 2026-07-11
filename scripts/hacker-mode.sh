#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Consola Pentesting HUD - 5 Pantallas)
# DESCRIPCIÓN: 4 cuadrantes fijos y una 5ª terminal flotante en el centro exacto
# ==============================================================================

# --- PARÁMETROS QUE EMULAN TU PANEL DE LINUX MINT ---
OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="13.0"

echo "[*] Desplegando estación de 5 terminales HUD..."

# 1. Lanzar el contenedor gigante de 4 cuadrantes (Esquinas fijas)
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

# Pausa milimétrica para permitir al servidor gráfico asentar la ventana base
sleep 0.5

# 2. Lanzar la 5ª Terminal: Flotante en el Centro Exacto (Cracking de Redes)
# Usamos un ancho de 650 y alto de 380. Forzamos su posición por comando.
kitty \
  -o remember_window_size=no \
  -o initial_window_width=750 \
  -o initial_window_height=400 \
  -o background_opacity="0.90" \
  -o background="#11111b" \
  -o foreground="#ff5555" \
  -o font_size="12.5" \
  -o hide_window_decorations=yes \
  -o window_padding_width=20 \
  --title "CENTRAL_CRACKING" \
  -e sh -c "echo '☠️  5. CENTRAL DE AUDITORÍA INALÁMBRICA & CRACKING'; echo '---------------------------------------------------'; echo '-> Herramientas listas: aircrack-ng, john, hashcat'; echo '-> Ejemplo: sudo aircrack-ng -w wordlist.txt captura.cap'; exec bash" &

sleep 0.6

# 3. Mover la terminal de cracking al centro geométrico del monitor usando wmctrl
# Coordenadas calculadas para un monitor estándar: X=550, Y=290
wmctrl -r "CENTRAL_CRACKING" -e 0,550,290,750,400

echo "[✔] Estación HUD unificada en 5 paneles."
