# Solución de problemas

## Conky no aparece
- Comprueba que está instalado: `conky --version` (el paquete es `conky-all`).
- Pruébalo a mano para ver errores: `conky -c ~/.config/conky/cyber-tactical/conky.conf`
- Si se ve con fondo negro sólido o sin transparencia, activa un compositor (Cinnamon lo trae activado por defecto).
- Con varios monitores, cambia `xinerama_head` en la plantilla.

## Los iconos salen como cuadros (▯)
La Nerd Font no está instalada o la caché no se actualizó:
```bash
fc-list | grep -i "JetBrainsMono Nerd"
fc-cache -f
```
Si no aparece, ejecuta `./scripts/install.sh --skip-deps` otra vez.

## `fastfetch` o `eza` no se instalan
No están en los repositorios de Mint 21. Descarga el `.deb` de fastfetch desde <https://github.com/fastfetch-cli/fastfetch/releases> o actualiza a Mint 22. El resto del entorno funciona sin ellos.

## Plank no usa el tema
```bash
dconf read /net/launchpad/plank/docks/dock1/theme   # debe mostrar CyberTactical
pkill plank; plank &
```
Si `dconf` no existe: `sudo apt install dconf-cli` y reinstala.

## La temperatura de CPU muestra N/A
Algunos equipos no exponen sensores en `/sys`. Prueba con `sudo apt install lm-sensors && sudo sensors-detect` y adapta `scripts/helpers/cpu-temp.sh`.

## La red aparece con la interfaz equivocada
Se detecta al instalar. Si cambiaste de WiFi a cable, reaplica: `./scripts/set-theme.sh <paleta>`.

## Quiero volver a como estaba
```bash
./scripts/uninstall.sh          # conserva las copias de seguridad
./scripts/uninstall.sh --purge  # las borra también
```
Los paquetes instalados con apt no se eliminan; puedes quitarlos con `sudo apt remove conky-all plank btop kitty`.

## Dónde se guarda todo
- Configuraciones: `~/.config/{conky,kitty,btop,fastfetch,cyber-tactical-mint}`
- Estado y copias de seguridad: `~/.local/state/cyber-tactical-mint/`
- Fuentes y fondos: `~/.local/share/{fonts,backgrounds}/…`
