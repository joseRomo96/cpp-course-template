#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$BUILD_DIR = "build"

Write-Host "▶ Cleaning previous build..."
if (Test-Path $BUILD_DIR) {
    Remove-Item -Recurse -Force $BUILD_DIR
}

Write-Host "▶ Configuring CMake (tests)..."
cmake -S . -B $BUILD_DIR `
    -DENABLE_TESTING=ON `
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
ctest --test-dir $BUILD_DIR --output-on-failure
if ($LASTEXITCODE -ne 0) {
    throw "Tests failed."
}

Write-Host "✔ Tests finished."
