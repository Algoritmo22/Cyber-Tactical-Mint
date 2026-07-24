#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Geometría HUD - 5 Pantallas Espaciadas)
# DESCRIPCIÓN: 4 Esquinas encuadradas y una 5ª terminal central estilo Rombo
# ==============================================================================

OPACIDAD="0.85"
COLOR_FONDO="#1e1e2e"
COLOR_TEXTO="#cdd6f4"
TAMANO_LETRA="12.0"

echo "[*] Desplegando geometría HUD espaciada..."

# Función para abrir las esquinas con un tamaño limpio y fijo para evitar apiñamiento
abrir_esquina() {
    local titulo="$1"
    local texto="$2"
    kitty \
      -o remember_window_size=no \
      -o initial_window_width=750 \
      -o initial_window_height=420 \
      -o background_opacity=$OPACIDAD \
      -o background=$COLOR_FONDO \
      -o foreground=$COLOR_TEXTO \
      -o font_size=$TAMANO_LETRA \
      -o hide_window_decorations=yes \
      -o window_padding_width=15 \
      --title "$titulo" \
      -e sh -c "echo '$texto'; exec bash" &
}

# 1. Desplegar los 4 cuadrantes encuadrados de forma independiente
abrir_esquina "HUD_TOP_LEFT" "🛰️  1. INTERCEPTOR Y MONITOREO DE REDES (tcpdump)"
sleep 0.2
abrir_esquina "HUD_TOP_RIGHT" "⚡ 2. CONSOLA DE ATAQUES / METASPLOIT"
sleep 0.2
abrir_esquina "HUD_BOTTOM_LEFT" "🔍 3. ESCANEO Y RECONOCIMIENTO (nmap)"
sleep 0.2
abrir_esquina "HUD_BOTTOM_RIGHT" "🤖 4. INTELIGENCIA ARTIFICIAL TÁCTICA (Dolphin)"
sleep 0.2

# 2. Desplegar la 5ª Terminal: Central de Cracking (Simulación de Rombo)
# - Fondo 100% invisible para que solo se vea el texto en rombo y el prompt
kitty \
  -o remember_window_size=no \
  -o initial_window_width=550 \
  -o initial_window_height=380 \
  -o background_opacity=0.0 \
  -o font_size=11.5 \
  -o foreground=#ff5555 \
  -o hide_window_decorations=yes \
  -o window_padding_width=10 \
  --title "HUD_CENTER_DIAMOND" \
  -e sh -c "
    clear;
    echo '         /\         ';
    echo '        /  \        ☠️  5. CENTRAL DE AUDITORÍA';
    echo '       / ☠️  \       ------------------------';
    echo '      / CRACK \     aircrack-ng / hcxtools  ';
    echo '     /  WIFI   \    ------------------------';
    echo '     \  MODE   /    Buscando Handshakes...  ';
    echo '      \       /     ';
    echo '       \     /      ';
    echo '        \   /       ';
    echo '         \/         ';
    exec bash
  " &

sleep 1.0 # Pausa crítica para permitir al sistema mapear las ventanas

# 3. Acomodo Milimétrico Espaciado en Pantalla (Resolución Estándar 1080p)
# [wmctrl -r TITULO -e gravedad, X, Y, Ancho, Alto]
wmctrl -r "HUD_TOP_LEFT"     -e 0,20,50,750,420
wmctrl -r "HUD_TOP_RIGHT"    -e 0,1150,50,750,420
wmctrl -r "HUD_BOTTOM_LEFT"  -e 0,20,560,750,420
wmctrl -r "HUD_BOTTOM_RIGHT" -e 0,1150,560,750,420

# Posicionar la terminal del Rombo exactamente en el centro libre que dejaron las esquinas
wmctrl -r "HUD_CENTER_DIAMOND" -e 0,685,320,550,380

echo "[✔] Estación HUD simétrica y espaciada completada."
