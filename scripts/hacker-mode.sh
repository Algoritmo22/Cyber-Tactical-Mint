#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Modo Hacker Multi-Ventana)
# ==============================================================================

# Nombre de la sesión de tmux
SESION="HackerHUD"

# 1. Iniciar sesión de tmux en segundo plano
tmux new-session -d -s $SESION

# 2. Ventana Superior Izquierda: Lanzar tu btop táctico
tmux send-keys -t $SESION "btop" C-m

# 3. Dividir verticalmente (Crea lado derecho)
tmux split-window -h -t $SESION

# 4. Ventana Superior Derecha: Simulación de tráfico de red / conexiones activa
tmux send-keys -t $SESION "watch -n 1 'ss -tupn | head -n 20'" C-m

# 5. Dividir el lado derecho horizontalmente (Crea ventana inferior derecha)
tmux split-window -v -t $SESION

# 6. Ventana Inferior Derecha: Mapa del mundo o traza táctica
tmux send-keys -t $SESION "ping -4 8.8.8.8" C-m

# 7. Regresar al lado izquierdo y dividirlo horizontalmente (Crea inferior izquierda)
tmux select-pane -t $SESION:0.0
tmux split-window -v -t $SESION
tmux send-keys -t $SESION "clear && fastfetch" C-m

# 8. Forzar el uso de tu terminal Kitty con el diseño Cyberpunk para abrir todo junto
kitty --override background_opacity=0.9 -e tmux attach-session -t $SESION
