#!/bin/bash

# ==============================================================================
# PROYECTO: Cyber-Tactical-Mint (Modo Hacker - Edición Barra de Estado)
# DESCRIPCIÓN: Consola unificada con la estética nativa de tu panel de sistema
# ==============================================================================

SESION="HackerHUD"

# 1. Iniciar sesión de tmux en segundo plano
tmux new-session -d -s $SESION

# --- CONFIGURACIÓN DE CONCORDANCIA CON LA BARRA DE ESTADO ---
# Eliminar las molestas líneas verdes y hacer los bordes totalmente invisibles
tmux set-option -g pane-border-style fg=default
tmux set-option -g pane-active-border-style fg=default
tmux set-option -g status off

# 2. Ventana Superior: Lanzar btop táctico ampliado
tmux send-keys -t $SESION "btop" C-m

# 3. Dividir horizontalmente (Crear espacio inferior amplio)
tmux split-window -v -t $SESION

# 4. Ventana Inferior: Información del sistema y terminal libre limpia
tmux send-keys -t $SESION "clear && fastfetch" C-m

# 5. Forzar la terminal Kitty a replicar los atributos de tu panel de escritorio
# - Opacidad equilibrada, fuentes amplias tamaño 13.5 y colores de interfaz Mint
kitty \
  -o background_opacity=0.88 \
  -o font_size=13.5 \
  -o window_padding_width=20 \
  -o hide_window_decorations=yes \
  -o foreground=#c5c6c7 \
  -o background=#1f2326 \
  -e tmux attach-session -t $SESION
