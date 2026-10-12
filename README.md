# ⚡ Cyber-Tactical-Mint ⚡

Un entorno de escritorio táctico, modular y automatizado optimizado para **Linux Mint (Cinnamon)** con estética Cyberpunk / Militar.

## 🛠️ Componentes de la Suite
* 🛰️ **Conky HUD**: Monitor de recursos adaptativo en tiempo real.
* 💻 **Kitty Terminal**: Emulador de terminal de alto rendimiento con transparencias y paleta neón.
* 📊 **Btop & Fastfetch**: Visualización avanzada de procesos e información del sistema.
* ⚓ **Plank Dock**: Barra de accesos directos táctica e intuitiva.

## 🚀 Instalación Rápida

Abre una terminal en tu sistema y ejecuta el siguiente bloque de comandos:

```bash
git clone https://github.com/Algoritmo22/Cyber-Tactical-Mint.git
cd Cyber-Tactical-Mint/scripts
chmod +x install.sh
sudo ./install.sh
```

## 🛡️ Centro de Seguridad Modular

Se añadió un menú opcional con módulos de diagnóstico de red, auditoría web autorizada, defensa y análisis forense. No ejecuta escaneos automáticamente.

```bash
bash scripts/security-center.sh
```

La documentación está en [docs/SECURITY-CENTER.md](docs/SECURITY-CENTER.md). Instala únicamente los módulos que necesites y utiliza las herramientas solo en sistemas propios o con autorización explícita.

## 🧠 Características Inteligentes del Instalador
* 🔍 **Auto-detección de red**: Escanea e inyecta la interfaz activa automáticamente en Conky.
* 🛡️ **Parcheo de Hardware**: Detecta la presencia de drivers gráficos para evitar bloqueos por llamadas fallidas a `nvidia-smi`.
* 📦 **Despliegue Autónomo**: Administra, copia e instala las fuentes tipográficas Nerd Fonts requeridas sin intervención del usuario.
