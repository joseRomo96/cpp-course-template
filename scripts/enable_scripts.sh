#!/usr/bin/env bash
set -e

# Directorio base (por defecto scripts/)
SCRIPTS_ROOT="${1:-scripts}"

if [ ! -d "$SCRIPTS_ROOT" ]; then
  echo "⚠ No scripts directory found at '${SCRIPTS_ROOT}'."
  exit 1
fi

echo "▶ Enabling executable bit for .sh and .ps1 inside '${SCRIPTS_ROOT}'..."

# Activa permisos de ejecución en Linux/macOS
find "$SCRIPTS_ROOT" -type f \( -name "*.sh" -o -name "*.ps1" \) -exec chmod +x {} \;

echo "✔ Scripts enabled."
