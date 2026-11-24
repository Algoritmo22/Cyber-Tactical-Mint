// Managed by Cyber-Tactical-Mint (paleta: @@THEME_NAME@@)
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",
  "logo": {
    "type": "auto",
    "color": { "1": "38;2;@@PRIMARY_RGB@@", "2": "38;2;@@SECONDARY_RGB@@" }
  },
  "display": {
    "separator": "  ➜  ",
    "color": { "keys": "38;2;@@SECONDARY_RGB@@", "title": "38;2;@@PRIMARY_RGB@@", "separator": "38;2;@@MUTED_RGB@@" }
  },
  "modules": [
    "title",
    { "type": "separator", "string": "─" },
    { "type": "os",        "key": "SISTEMA  " },
    { "type": "host",      "key": "EQUIPO   " },
    { "type": "kernel",    "key": "KERNEL   " },
    { "type": "uptime",    "key": "UPTIME   " },
    { "type": "packages",  "key": "PAQUETES " },
    { "type": "shell",     "key": "SHELL    " },
    { "type": "de",        "key": "ESCRITORIO" },
    { "type": "terminal",  "key": "TERMINAL " },
    { "type": "cpu",       "key": "CPU      " },
    { "type": "gpu",       "key": "GPU      " },
    { "type": "memory",    "key": "RAM      " },
    { "type": "disk",      "key": "DISCO    " },
    { "type": "localip",   "key": "RED      " },
    "break",
    "colors"
  ]
}
