# Guía de personalización

## 1. Crear tu propia paleta

```bash
cp palettes/cyber.sh palettes/mipaleta.sh
$EDITOR palettes/mipaleta.sh        # cambia P_NAME y los colores (hex SIN #)
./scripts/set-theme.sh mipaleta
python3 tools/make_wallpapers.py    # opcional: genera un fondo con tu paleta
```

| Variable | Uso |
|---|---|
| `P_BG`, `P_BG_ALT` | Fondo principal y fondo secundario (barras, pestañas inactivas) |
| `P_FG` | Texto normal |
| `P_PRIMARY` | Color principal (títulos, barras, cursor) |
| `P_SECONDARY` | Color secundario (enlaces, gráficas) |
| `P_ACCENT` | Acentos (secciones del HUD, selección) |
| `P_WARN`, `P_DANGER` | Avisos y errores |
| `P_MUTED` | Texto apagado, bordes |
| `P_GTK_THEME`, `P_ICON_THEME` | Tema GTK e iconos que usa `--with-system-theme` |

## 2. Tokens disponibles en las plantillas

Por cada color `X` de la tabla anterior (sin el prefijo `P_`):

| Token | Ejemplo para `PRIMARY=00ff9c` |
|---|---|
| `@@PRIMARY@@` | `00ff9c` |
| `@@PRIMARY_RGB@@` | `0;255;156` |
| `@@PRIMARY_R@@` `_G` `_B` | `0` `255` `156` |

Además: `@@FONT_MONO@@`, `@@NET_IFACE@@`, `@@BATTERY@@`, `@@THEME_NAME@@`, `@@HOME_DIR@@`, `@@CONKY_DIR@@`, `@@CONKY_CONF@@`, `@@CTM_HOME@@`.
Las líneas `@@GPU_BLOCK@@` y `@@BATT_BLOCK@@` de Conky se sustituyen por `configs/conky/blocks/*.txt` solo si hay hardware compatible.

## 3. Cambiar el HUD de Conky

Edita `configs/conky/conky.conf.tpl` y reaplica:

```bash
./scripts/set-theme.sh cyber
```

Ideas: cambiar `alignment` (`top_left`, `bottom_right`…), `gap_x/gap_y`, la opacidad `own_window_argb_value`, o añadir secciones.

## 4. Mostrar fastfetch al abrir cada terminal

En `configs/shell/shell.sh.tpl`, descomenta la última línea y reaplica.

## 5. Atajos recomendados de Cinnamon

En *Configuración del sistema → Teclado → Atajos*:

| Atajo | Acción |
|---|---|
| `Ctrl+Alt+T` | Abrir Kitty (ya configurada como terminal predeterminada) |
| `Ctrl+Shift+Esc` | Comando personalizado: `kitty --class btop -e btop` |
| `Super+H` | Comando personalizado: `bash -ic hud` (activar/desactivar HUD) |

Atajos dentro de Kitty: `Ctrl+Alt+H` / `Ctrl+Alt+V` dividen la ventana; `Ctrl+Alt+flechas` cambian de panel; `Ctrl+Shift+Z` maximiza el panel; `Ctrl+Shift+U/D` ajustan la transparencia.
