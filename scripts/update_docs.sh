#!/usr/bin/env bash
set -e

# --- helper: silent exec ---
run_quiet() {
    "$@" >/dev/null 2>&1
}

DOXYFILE="docs/Doxyfile"

echo "▶ Running Doxygen..."

# 1) Verificar que exista el Doxyfile
if [ ! -f "${DOXYFILE}" ]; then
    echo "❌ ERROR: Missing Doxyfile at ${DOXYFILE}"
    exit 1
fi

# 2) Detectar el OUTPUT_DIRECTORY configurado
OUT_DIR=$(grep -E "^[[:space:]]*OUTPUT_DIRECTORY" "${DOXYFILE}" | sed 's/[^=]*= *//')

# Si está vacío → usar por defecto
if [ -z "${OUT_DIR}" ]; then
    OUT_DIR="docs/html"
fi

# 3) Crear carpeta si no existe
mkdir -p "${OUT_DIR}"

# 4) Ejecutar doxygen silenciosamente, pero si falla → mostrar error real
if ! run_quiet doxygen "${DOXYFILE}"; then
    echo "❌ Doxygen failed — showing full output:"
    doxygen "${DOXYFILE}"
    exit 1
fi

echo "✔ Doxygen documentation generated at ${OUT_DIR}"
