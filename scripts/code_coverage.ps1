#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$BUILD_DIR         = "build"
$TMP_DIR           = "tmp"

Write-Host "▶ Preparing directories..."
New-Item -ItemType Directory -Force -Path $TMP_DIR | Out-Null

Write-Host "▶ Cleaning previous build..."
if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
}

Write-Host "▶ Configuring CMake (tests + coverage)..."
cmake -S . -B $BUILD_DIR `
    -DENABLE_TESTING=ON `
    -DENABLE_COVERAGE=ON `
    -DCMAKE_BUILD_TYPE=Debug
if ($LASTEXITCODE -ne 0) {
    throw "CMake configure failed."
}

Write-Host "▶ Building project..."
cmake --build $BUILD_DIR --parallel
if ($LASTEXITCODE -ne 0) {
    throw "Build failed."
}

Write-Host "▶ Running unit tests..."
$ctestXml = Join-Path $TMP_DIR "ctest.xml"
ctest --test-dir $BUILD_DIR `
      --output-on-failure `
      --output-junit $ctestXml
if ($LASTEXITCODE -ne 0) {
    throw "Tests failed."
}

$rawInfo      = Join-Path $TMP_DIR "coverage.raw.info"
$filteredInfo = Join-Path $TMP_DIR "coverage.filtered.info"
$finalInfo    = Join-Path $TMP_DIR "coverage.final.info"

Write-Host "▶ Capturing coverage (lcov)..."
lcov --directory $BUILD_DIR `
     --capture `
     --output-file $rawInfo `
     --rc derive_function_end_line=0 `
     --ignore-errors inconsistent,unsupported,format,unused
if ($LASTEXITCODE -ne 0) {
    throw "lcov capture failed."
}

Write-Host "▶ Filtering coverage..."
lcov --remove $rawInfo `
     '/usr/*' `
     '*/_deps/*' `
     '*/course/tests/*' `
     '*/student/tests/*' `
     --output-file $filteredInfo `
     --ignore-errors unused
if ($LASTEXITCODE -ne 0) {
    throw "lcov remove failed."
}

Write-Host "▶ Extracting course-related coverage..."
lcov --extract $filteredInfo `
     '*course/src/*' `
     '*course/include/*' `
     '*student/src/*' `
     '*student/include/*' `
     --output-file $finalInfo `
     --ignore-errors unused
if ($LASTEXITCODE -ne 0) {
    throw "lcov extract failed."
}

Write-Host "▶ Coverage summary..."
lcov --list $finalInfo 2>&1 `
  | Select-String -Pattern '\.cpp\|' ,'Total:' `
  | ForEach-Object { $_.Line }

Write-Host "▶ Cleaning temporary files..."
if (Test-Path $TMP_DIR) {
    Remove-Item -Recurse -Force $TMP_DIR
}

Write-Host "✔ Coverage completed."
