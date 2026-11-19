# Centro de Seguridad — Cyber-Tactical-Mint

## Objetivo
Añade un menú modular de herramientas para Linux Mint Cinnamon, manteniendo la estética verde/cian y evitando que la instalación ejecute escaneos o pruebas por sí sola.

## Requisitos
- Linux Mint Cinnamon o Ubuntu compatible con APT.
- Usuario normal con permisos para ejecutar `sudo` cuando APT los necesite.
- Conexión a Internet para descargar paquetes.

## Ejecutar
Desde la raíz del repositorio:

```bash
bash scripts/security-center.sh
```

El menú guarda su registro en `~/.local/state/cyber-tactical-mint/security-center.log`.

## Módulos
- Base y diagnóstico: utilidades generales y terminal.
- Diagnóstico de red: Nmap, tcpdump, Wireshark, mtr, arp-scan y herramientas afines.
- Auditoría web: Nikto, SQLmap, Gobuster y WhatWeb. Úsalos solo contra aplicaciones propias o con permiso explícito.
- Defensa: Lynis, Fail2ban, UFW, ClamAV, YARA y rkhunter.
- Forense: Sleuth Kit, TestDisk, Foremost, Binwalk, Radare2, GDB y ExifTool.

Los paquetes disponibles pueden variar según la versión y los repositorios configurados. Si APT no encuentra un paquete, cancela el módulo y consulta el nombre disponible para tu versión.

## Salvaguardas
- No ejecutes el menú como root; se solicita sudo solo para instalar.
- El descubrimiento de red pide un rango y confirmación antes de ejecutar `nmap -sn`.
- No incluye explotación automática, robo de credenciales, persistencia ni desactivación de controles.
- La instalación de UFW no activa ni cambia reglas automáticamente.
- Revisa el registro antes de reportar un resultado.

## Próximas mejoras
- Integración con Cinnamon y un lanzador .desktop.
- Comprobaciones de compatibilidad por paquete y versión.
- Panel visual de estado de servicios y firewall.
- Pruebas automatizadas en una máquina virtual limpia.
