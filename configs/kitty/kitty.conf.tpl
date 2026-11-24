# Managed by Cyber-Tactical-Mint (paleta: @@THEME_NAME@@)
# Se genera desde configs/kitty/kitty.conf.tpl.

# ── Tipografía ──
font_family      @@FONT_MONO@@
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        11.0

# ── Ventana ──
background_opacity      0.88
dynamic_background_opacity yes
window_padding_width    10
confirm_os_window_close 0
enable_audio_bell       no
remember_window_size    yes
copy_on_select          clipboard
scrollback_lines        10000
url_style               curly

# ── Cursor ──
cursor_shape            beam
cursor_blink_interval   0.6

# ── Pestañas ──
tab_bar_edge            top
tab_bar_style           powerline
tab_powerline_style     slanted
tab_title_template      "{index}: {title}"
active_tab_foreground   #@@BG@@
active_tab_background   #@@PRIMARY@@
active_tab_font_style   bold
inactive_tab_foreground #@@FG@@
inactive_tab_background #@@BG_ALT@@
tab_bar_background      #@@BG@@

# ── Divisiones ──
enabled_layouts         splits,stack
active_border_color     #@@PRIMARY@@
inactive_border_color   #@@MUTED@@
bell_border_color       #@@WARN@@

# ── Colores ──
foreground              #@@FG@@
background              #@@BG@@
selection_foreground    #@@BG@@
selection_background    #@@SECONDARY@@
cursor                  #@@PRIMARY@@
cursor_text_color       #@@BG@@
url_color               #@@SECONDARY@@

color0  #@@BG_ALT@@
color8  #@@MUTED@@
color1  #@@DANGER@@
color9  #@@DANGER@@
color2  #@@PRIMARY@@
color10 #@@PRIMARY@@
color3  #@@WARN@@
color11 #@@WARN@@
color4  #@@SECONDARY@@
color12 #@@SECONDARY@@
color5  #@@ACCENT@@
color13 #@@ACCENT@@
color6  #@@SECONDARY@@
color14 #@@SECONDARY@@
color7  #@@FG@@
color15 #ffffff

# ── Atajos ──
map ctrl+shift+t       new_tab_with_cwd
map ctrl+alt+h         launch --location=hsplit --cwd=current
map ctrl+alt+v         launch --location=vsplit --cwd=current
map ctrl+alt+left      neighboring_window left
map ctrl+alt+right     neighboring_window right
map ctrl+alt+up        neighboring_window up
map ctrl+alt+down      neighboring_window down
map ctrl+shift+z       toggle_layout stack
map ctrl+shift+u       change_background_opacity +0.05
map ctrl+shift+d       change_background_opacity -0.05
map f11                toggle_fullscreen
