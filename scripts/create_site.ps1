#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$BUILD_DIR         = "build"
$TMP_DIR           = "tmp"
$COVERAGE_SITE_DIR = "site/coverage"
$TESTS_SITE_DIR    = "site/tests"

Write-Host "▶ Preparing directories..."
New-Item -ItemType Directory -Force -Path $TMP_DIR, $COVERAGE_SITE_DIR, $TESTS_SITE_DIR | Out-Null

Write-Host "▶ Cleaning previous build..."
if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
}

Write-Host "▶ Configuring CMake (tests + coverage)..."
& cmake -S . -B $BUILD_DIR `
    -DENABLE_TESTING=ON `
    -DENABLE_COVERAGE=ON `
    -DCMAKE_BUILD_TYPE=Debug
if ($LASTEXITCODE -ne 0) {
    throw "CMake configure failed."
}

Write-Host "▶ Building project..."
& cmake --build $BUILD_DIR --parallel
if ($LASTEXITCODE -ne 0) {
    throw "Build failed."
}

# --- Tests + JUnit ---
$junitPath = Join-Path $TMP_DIR "ctest.xml"

Write-Host "▶ Running unit tests (with JUnit output)..."
& ctest --test-dir $BUILD_DIR `
        --output-on-failure `
        --output-junit $junitPath
if ($LASTEXITCODE -ne 0) {
    throw "Tests failed."
}

# --- Coverage HTML (usa code_coverage.ps1 si quieres reusar lógica) ---
Write-Host "▶ Capturing coverage (lcov)..."
$rawInfo      = Join-Path $TMP_DIR "coverage.raw.info"
$filteredInfo = Join-Path $TMP_DIR "coverage.filtered.info"
$finalInfo    = Join-Path $TMP_DIR "coverage.final.info"

& lcov --directory $BUILD_DIR `
       --capture `
       --output-file $rawInfo `
       --rc derive_function_end_line=0 `
       --ignore-errors inconsistent,unsupported,format,unused
if ($LASTEXITCODE -ne 0) {
    throw "lcov capture failed."
}

& lcov --remove $rawInfo `
       '/usr/*' `
       '*/_deps/*' `
       '*/course/tests/*' `
       '*/student/tests/*' `
       --output-file $filteredInfo `
       --ignore-errors unused
if ($LASTEXITCODE -ne 0) {
    throw "lcov remove failed."
}

& lcov --extract $filteredInfo `
       '*course/src/*' `
       '*course/include/*' `
       '*student/src/*' `
       '*student/include/*' `
       --output-file $finalInfo `
       --ignore-errors unused
if ($LASTEXITCODE -ne 0) {
    throw "lcov extract failed."
}

Write-Host "▶ Generating coverage HTML..."
& genhtml $finalInfo --output-directory $COVERAGE_SITE_DIR
if ($LASTEXITCODE -ne 0) {
    throw "genhtml failed."
}

# --- HTML de tests usando tu script Python ---
$testsIndex = Join-Path $TESTS_SITE_DIR "index.html"

Write-Host "▶ Generating tests report HTML..."
& python3 "scripts/private/render_ctest_report.py" $junitPath $testsIndex
if ($LASTEXITCODE -ne 0) {
    throw "render_ctest_report.py failed."
}

# --- site/index.html (landing) ---
Write-Host "▶ Generating site/index.html..."
@'
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="utf-8" />
  <title>Curso C++</title>
</head>
<body>
  <h1>Curso C++</h1>
  <ul>
    <li><a href="coverage/index.html">Cobertura de código</a></li>
    <li><a href="tests/index.html">Reporte de tests</a></li>
    <li><a href="docs/html/index.html">Documentación Doxygen</a></li>
  </ul>
</body>
</html>
'@ | Set-Content -Encoding UTF8 "site/index.html"

# --- Doxygen ---
Write-Host "▶ Running Doxygen..."
& doxygen "docs/Doxyfile"
if ($LASTEXITCODE -ne 0) {
    throw "Doxygen failed."
}

Write-Host "▶ Cleaning temporary files..."
if (Test-Path $TMP_DIR) {
    Remove-Item -Recurse -Force $TMP_DIR
}

Write-Host ""
Write-Host "🚀 Full CI pipeline completed successfully."
