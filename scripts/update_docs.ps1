#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

$Doxyfile = "docs/Doxyfile"

Write-Host "▶ Running Doxygen..."

if (-not (Test-Path $Doxyfile)) {
    Write-Error "Doxyfile not found at $Doxyfile"
    exit 1
}

doxygen $Doxyfile
if ($LASTEXITCODE -ne 0) {
    throw "Doxygen failed."
}

Write-Host "✔ Doxygen documentation generated."
