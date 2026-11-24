<div align="center">

# ⚡ Cyber-Tactical-Mint ⚡

**Un escritorio táctico, modular y reversible para Linux Mint (Cinnamon)**
Estética cyberpunk / militar · una sola paleta para todo · instalación en un comando

![Linux Mint](https://img.shields.io/badge/Linux%20Mint-21%20%7C%2022-87CF3E?logo=linuxmint&logoColor=white)
![Cinnamon](https://img.shields.io/badge/Desktop-Cinnamon-orange)
![Shell](https://img.shields.io/badge/Made%20with-Bash-4EAA25?logo=gnubash&logoColor=white)

<img src="docs/img/wallpaper-cyber.jpg" alt="Fondo Cyber" width="80%">

</div>

<!--
  TODO: añade aquí capturas reales de tu escritorio (por ejemplo docs/img/desktop-cyber.png)
  y un GIF corto. Es lo que más ayuda a que otras personas quieran probarlo.
-->

## 🛠️ ¿Qué incluye?

| Componente | Qué hace |
|---|---|
| 🛰️ **Conky HUD** | Monitor en el escritorio: CPU (+ temperatura), RAM, disco, red, procesos. Añade GPU NVIDIA y batería **solo si existen**. |
| 💻 **Kitty** | Terminal rápida con transparencia, pestañas tipo powerline, divisiones de ventana y colores de la paleta. |
| 📊 **Btop** | Monitor de procesos con tema propio. |
| 🧾 **Fastfetch** | Información del sistema con los colores de la paleta. |
| ⚓ **Plank** | Dock oscuro con borde neón, zoom e ocultamiento inteligente. |
| 🐚 **Shell** | Prompt táctico (o [Starship](https://starship.rs) si lo activas), alias útiles, `zoxide`/`fzf` opcionales. |
| 🖼️ **Fondos** | 3 fondos 4K generados con la misma paleta. |

### 🎨 Paletas

| Nombre | Estilo |
|---|---|
| `cyber` *(por defecto)* | Negro azulado + verde neón, cian y magenta |
| `military` | Verde oliva, arena y naranja de señalización |
| `amber` | Terminal retro ámbar sobre negro cálido |

Todas las configuraciones se **generan desde plantillas** (`configs/*.tpl`) y un único archivo de colores por paleta (`palettes/*.sh`). Cambiar de paleta recolorea todo a la vez.

## 🚀 Instalación

```bash
cd ~
git clone https://github.com/Algoritmo22/Cyber-Tactical-Mint.git
cd Cyber-Tactical-Mint
./scripts/install.sh --dry-run     # (opcional) mira qué haría, sin tocar nada
./scripts/install.sh
```

> ⚠️ **No uses `sudo ./install.sh`.** Las configuraciones son de tu usuario; el script pide `sudo` solo para instalar paquetes con `apt`.

Abre una terminal nueva (`Ctrl+Alt+T`) y listo.

### Opciones útiles

```text
-t, --theme NOMBRE      cyber | military | amber
-n, --dry-run           muestra los cambios sin aplicarlos
    --with-extras       instala también fzf, bat, zoxide y eza (si tu versión de Mint los tiene)
    --with-starship     instala el prompt Starship desde starship.rs
    --with-system-theme tema GTK, iconos y tema de Cinnamon a juego (usa los que trae Mint)
    --skip-deps         no instala paquetes con apt
    --skip-fonts        no descarga la Nerd Font
    --skip-wallpaper    no cambia el fondo
    --no-launch         no inicia Conky/Plank al terminar
```

Ejemplo completo: `./scripts/install.sh --theme military --with-extras --with-system-theme`

## 🔁 Uso diario

```bash
./scripts/set-theme.sh amber     # cambia la paleta de todo el entorno
ctm-theme military               # lo mismo, desde cualquier carpeta (alias de la shell)
hud                              # activa/desactiva el HUD de Conky (hud on | hud off)
./scripts/update.sh              # git pull + reaplica la paleta actual
./scripts/uninstall.sh           # deshace TODO y restaura tus archivos originales
```

## 🧠 Características inteligentes del instalador

- 🔍 **Auto-detección de red**: usa la interfaz con la ruta por defecto (no el `eth0`/`wlan0` fijo).
- 🛡️ **Hardware adaptable**: el bloque de GPU solo aparece si `nvidia-smi` funciona (evita errores y bloqueos); el de batería, solo en portátiles.
- 💾 **Copias de seguridad**: la primera vez que toca un archivo tuyo, guarda el original en `~/.local/state/cyber-tactical-mint/original/`.
- ↩️ **100 % reversible**: `uninstall.sh` restaura esos originales, elimina lo que creó y devuelve los ajustes de escritorio a sus valores anteriores.
- 🧪 **Modo `--dry-run`** y **reinstalación segura** (puedes ejecutarlo varias veces sin duplicar nada).
- 📦 **Dependencias solo si faltan**, y avisa claramente de las que no existan en tus repositorios.
- 🔤 **Nerd Font automática** (JetBrainsMono) con respaldo a una fuente del sistema si falla la descarga.

## 📁 Estructura

```text
Cyber-Tactical-Mint/
├── palettes/        # un archivo de colores por paleta (la única fuente de verdad)
├── configs/         # plantillas: conky, kitty, btop, fastfetch, plank, shell, starship, autostart
├── scripts/         # install.sh · uninstall.sh · update.sh · set-theme.sh · lib/ · helpers/
├── wallpapers/      # fondos 4K (generados con tools/make_wallpapers.py)
├── tools/           # generador de fondos
├── docs/            # guías de personalización y solución de problemas
└── cyber-tactical-mint.sh   # atajo que llama a scripts/install.sh
```

## 🎛️ Personalizar

Resumen rápido (guía completa en [docs/CUSTOMIZE.md](docs/CUSTOMIZE.md)):

- **Crear tu propia paleta**: copia `palettes/cyber.sh` a `palettes/mipaleta.sh`, cambia los colores y ejecuta `./scripts/set-theme.sh mipaleta`.
- **Regenerar fondos** con tu paleta: `python3 tools/make_wallpapers.py`.
- **Editar el HUD**: modifica `configs/conky/conky.conf.tpl` y reaplica con `./scripts/set-theme.sh <paleta>`.

## 🩺 ¿Algo no funciona?

Mira [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md): cubre Conky que no aparece, iconos que salen como cuadros, `fastfetch` que no está en tus repos, Plank sin tema, etc.

## ✅ Compatibilidad

Diseñado para **Linux Mint 21.x y 22.x con Cinnamon** (también funciona en Ubuntu/Debian con Cinnamon, usando `--force` si hace falta). En Mint 21, `fastfetch` y `eza` no están en los repositorios: el instalador te lo indica y el resto funciona igual.

## 🤝 Contribuir

Issues y pull requests son bienvenidos. Antes de enviar cambios en los scripts, ejecuta `shellcheck scripts/*.sh scripts/lib/*.sh` (también corre automáticamente en GitHub Actions).

## 📜 Licencia

Consulta el archivo [LICENSE](LICENSE) del repositorio.
