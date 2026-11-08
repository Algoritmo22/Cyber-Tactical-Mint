# ⚡ Cyber-Tactical-Mint ⚡

Entorno de escritorio táctico, modular y automatizado para **Linux Mint (Cinnamon)** con estética Cyberpunk / Militar.

> 📸 **Captura:** añade aquí una imagen de tu escritorio: `![Escritorio](docs/screenshot.png)`

## 🛠️ Componentes

| Componente | Descripción |
|---|---|
| 🛰️ **Conky HUD** | Panel con **relojes estilo tablero de carreras**: carga de CPU, temperatura de CPU, RAM y GPU, más red y uptime |
| 💻 **Kitty** | Terminal de alto rendimiento con transparencia y paleta neón |
| 📊 **Btop + Fastfetch** | Monitor de procesos e información del sistema |
| ⚓ **Plank** | Dock táctico |

## 🏎️ Relojes del HUD

- **CPU LOAD**: uso total de CPU.
- **CPU TEMP**: lee `coretemp`/`k10temp` o la zona térmica del sistema. Escala 0–110 °C.
- **RAM**: porcentaje y cantidad usada/total.
- **GPU**: porcentaje de uso y temperatura.
  - NVIDIA: vía `nvidia-smi` (si no está instalado, no se llama, así no hay bloqueos).
  - AMD: vía `/sys/class/drm`.
  - Intel integrada o máquinas virtuales: el reloj muestra `N/A`.

El arco pasa de cian a ámbar y a rojo según la carga, como un cuentarrevoluciones.

## 🚀 Instalación

```bash
cd ~
git clone https://github.com/Algoritmo22/Cyber-Tactical-Mint.git
cd Cyber-Tactical-Mint
chmod +x scripts/install.sh
./scripts/install.sh
```

> ⚠️ **No uses `sudo ./install.sh`.** Ejecuta el script como usuario normal; él pide `sudo` solo para instalar paquetes con apt. Si lo ejecutas como root, las configuraciones acabarían en `/root`.

Opciones:

```bash
./scripts/install.sh --dry-run     # muestra qué haría, sin cambiar nada
./scripts/install.sh --uninstall   # quita autoarranques y restaura el respaldo
```

## 🧠 Qué hace el instalador

- Respalda tus configuraciones actuales en `~/.cyber-tactical-mint-backup/` antes de sobrescribir.
- Detecta la interfaz de red activa y la inyecta en Conky.
- Instala JetBrainsMono Nerd Font verificando su checksum.
- Se puede ejecutar varias veces sin romper nada.
- Configura el autoarranque de Conky y Plank.

## 🎨 Personalización

Todo está en `configs/conky/`:

- `gauges.lua`: tamaño (`R`), posiciones, rangos (`110` para temperatura) y colores (`seg_color`).
- `conky.conf`: posición en pantalla (`alignment`, `gap_x`, `gap_y`) y fuente.

Para recargar: `pkill conky; conky -c ~/.config/conky/conky.conf &`

## 🩺 Solución de problemas

| Problema | Solución |
|---|---|
| No aparecen los relojes | Verifica `conky-all` (no `conky` a secas): `conky --version \| grep -i lua` |
| CPU TEMP marca `N/A` | En VMs no hay sensores. En equipo real ejecuta `sudo sensors-detect` |
| Fondo negro en lugar de transparente | Activa el compositor de Cinnamon o usa `own_window_type = 'normal'` |
| Iconos raros en terminal | Selecciona *JetBrainsMono Nerd Font* en tu terminal |

## 📁 Estructura

```
configs/      Configuraciones (conky, kitty, btop, fastfetch)
scripts/      install.sh
wallpapers/   Fondos de pantalla
```

## 📄 Licencia

Consulta el archivo [LICENSE](LICENSE).
