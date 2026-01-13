#!/usr/bin/env bash
set -e

SCRIPTS_ROOT="${1:-scripts}"

if [ ! -d "$SCRIPTS_ROOT" ]; then
  echo "⚠ No scripts directory found at '${SCRIPTS_ROOT}'."
  exit 1
fi

echo "▶ Removing executable bit for .sh and .ps1 inside '${SCRIPTS_ROOT}'..."

find "$SCRIPTS_ROOT" -type f \( -name "*.sh" -o -name "*.ps1" \) -exec chmod -x {} \;

echo "✔ Scripts disabled."
