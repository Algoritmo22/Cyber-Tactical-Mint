#!/usr/bin/env bash
# Atajo de compatibilidad: llama al instalador real.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/install.sh" "$@"
