# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/).

## [2.0.0] - 2026-11-23

### Añadido
- **Sistema de paletas** (`cyber`, `military`, `amber`): un archivo de colores por paleta y plantillas `@@COLOR@@` para todas las configuraciones.
- `scripts/uninstall.sh`: restaura los archivos originales y revierte los ajustes de escritorio.
- `scripts/set-theme.sh` y `scripts/update.sh`.
- Modo `--dry-run`, opciones `--theme`, `--with-extras`, `--with-starship`, `--with-system-theme`, `--skip-*`.
- Copias de seguridad automáticas de los archivos del usuario antes de modificarlos.
- Bloques opcionales del HUD: GPU NVIDIA y batería, solo si se detecta el hardware.
- Lectura de temperatura de CPU sin dependencias (`cpu-temp.sh`).
- Shell: prompt táctico, alias, función `hud`, integración opcional con `zoxide`, `fzf`, `eza`, `bat` y Starship.
- Kitty: pestañas powerline, divisiones de ventana y atajos.
- Tema de Plank propio y ajustes del dock (zoom, ocultamiento inteligente).
- Tres fondos de pantalla 4K y su generador (`tools/make_wallpapers.py`).
- Inicio automático de Conky y Plank.
- GitHub Actions: `shellcheck` y prueba del instalador en modo `--dry-run`.
- Documentación: `docs/CUSTOMIZE.md` y `docs/TROUBLESHOOTING.md`.

### Cambiado
- El instalador **ya no se ejecuta con `sudo`**; solo pide `sudo` para `apt`.
- El README corrige el comando de instalación (`git clone` con la URL completa).
- `cyber-tactical-mint.sh` queda como atajo hacia `scripts/install.sh`.

## [1.x]
- Versión inicial: Conky, Kitty, Btop, Fastfetch y Plank con instalador básico.
