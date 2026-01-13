#!/usr/bin/env bash
set -e

# --- helper: execute silently ---
run_quiet() {
  "$@" >/dev/null 2>&1
}

# Base folders
BUILD_DIR="build"
TMP_DIR="tmp"
COVERAGE_SITE_DIR="site/coverage"
TESTS_SITE_DIR="site/tests"

echo "▶ Preparing directories..."
mkdir -p "${TMP_DIR}" "${COVERAGE_SITE_DIR}" "${TESTS_SITE_DIR}"

echo "▶ Cleaning previous build..."
rm -rf "${BUILD_DIR}"

echo "▶ Configuring CMake (tests + coverage)..."
run_quiet cmake -S . -B "${BUILD_DIR}" \
  -DENABLE_TESTING=ON \
  -DENABLE_COVERAGE=ON \
  -DCMAKE_BUILD_TYPE=Debug \
  --log-level=ERROR

echo "▶ Building project..."
run_quiet cmake --build "${BUILD_DIR}" --parallel

echo "▶ Running unit tests..."
if ! ctest --test-dir "${BUILD_DIR}" \
           --output-junit "../${TMP_DIR}/ctest.xml" \
           --output-on-failure >/dev/null 2>&1; then
  echo ""
  echo "❌ Tests FAILED — showing full output:"
  ctest --test-dir "${BUILD_DIR}" --output-on-failure
  exit 1
fi

echo "▶ Capturing coverage (lcov)..."
run_quiet lcov --quiet \
  --directory "${BUILD_DIR}" \
  --capture \
  --output-file "${TMP_DIR}/coverage.raw.info" \
  --rc derive_function_end_line=0 \
  --ignore-errors inconsistent,unsupported,format,unused

echo "▶ Filtering coverage..."
run_quiet lcov --quiet \
  --remove "${TMP_DIR}/coverage.raw.info" \
    '/usr/*' \
    '*/_deps/*' \
    '*/course/tests/*' \
    '*/student/tests/*' \
  --output-file "${TMP_DIR}/coverage.filtered.info" \
  --ignore-errors unused

echo "▶ Extracting course-related coverage..."
run_quiet lcov --quiet \
  --extract "${TMP_DIR}/coverage.filtered.info" \
    '*course/src/*' \
    '*course/include/*' \
    '*student/src/*' \
    '*student/include/*' \
  --output-file "${TMP_DIR}/coverage.final.info" \
  --ignore-errors unused

echo "▶ Coverage summary..."
lcov --list "${TMP_DIR}/coverage.final.info" 2>&1

echo "▶ Cleaning temporary files..."
rm -rf "${TMP_DIR}"
rm -rf "${BUILD_DIR}"
