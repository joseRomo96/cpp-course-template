#!/usr/bin/env bash
set -e

# --- helper: execute silently ---
run_quiet() {
  "$@" >/dev/null 2>&1
}

BUILD_DIR="build"
TMP_DIR="tmp"

# --- cleanup siempre, pase lo que pase ---
cleanup() {
  echo "▶ Cleaning temporary files..."
  rm -rf "${TMP_DIR}" 2>/dev/null || true
  rm -rf "${BUILD_DIR}" 2>/dev/null || true
}
trap cleanup EXIT

echo "▶ Cleaning previous build..."
rm -rf "${BUILD_DIR}"

echo "▶ Configuring CMake (tests)..."
run_quiet cmake -S . -B "${BUILD_DIR}" \
  -DENABLE_TESTING=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  --log-level=ERROR

echo "▶ Building project..."
run_quiet cmake --build "${BUILD_DIR}" --parallel

echo "▶ Running unit tests..."
ctest --test-dir "${BUILD_DIR}" --output-on-failure

echo "✔ Tests finished."
