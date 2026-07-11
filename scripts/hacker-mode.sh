#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Modo Hacker Stealth V2)
# DESCRIPCIÓN: Consola táctica multiplexada con diseño minimalista y opaco
# ==============================================================================

SESION="HackerHUD"

# 1. Iniciar sesión de tmux en segundo plano
tmux new-session -d -s $SESION

# --- CONFIGURACIÓN ESTÉTICA EN CALIENTE PARA TMUX (Líneas y bordes discretos) ---
# Bordes de ventanas en gris oscuro opaco en lugar de verde brillante
tmux set-option -g pane-border-style fg="#1d2021"
tmux set-option -g pane-active-border-style fg="#32302f"
# Ocultar barra de estado inferior para ganar espacio limpio en las ventanas
tmux set-option -g status off

# 2. Ventana Superior Izquierda: Lanzar btop táctico
tmux send-keys -t $SESION "btop" C-m

# 3. Dividir verticalmente (Crea lado derecho)
tmux split-window -h -t $SESION

# 4. Ventana Superior Derecha: Conexiones de red activas en formato limpio
tmux send-keys -t $SESION "watch -t -n 2 'ss -tupn | head -n 15'" C-m

# 5. Dividir el lado derecho horizontalmente (Crea ventana inferior derecha)
tmux split-window -v -t $SESION

# 6. Ventana Inferior Derecha: Ping táctico limpio hacia la red
tmux send-keys -t $SESION "ping -4 -q 8.8.8.8 | grep --line-buffered -E 'bytes from|time='" C-m

# 7. Regresar al lado izquierdo y dividirlo horizontalmente (Crea inferior izquierda)
tmux select-pane -t $SESION:0.0
tmux split-window -v -t $SESION
tmux send-keys -t $SESION "clear && fastfetch" C-m

# 8. Forzar el uso de Kitty inyectando colores opacos, fuentes grandes y alta transparencia
kitty \
  -o background_opacity=0.92 \
  -o font_size=13.0 \
  -o foreground=#a89984 \
  -o background=#0e1111 \
  -o color2=#8ec07c \
  -e tmux attach-session -t $SESION
