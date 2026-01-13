#!/usr/bin/env pwsh
$ErrorActionPreference = "Stop"

Write-Host "▶ C++ Course Template — Setup (Windows)" -ForegroundColor Cyan
Write-Host "   Script root: $PSScriptRoot"
Write-Host ""

function Test-Tool {
    param (
        [string]$Name,
        [string]$Pretty
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) {
        Write-Host ("  ✔ {0,-10} found at {1}" -f $Pretty, $cmd.Source)
        return $true
    } else {
        Write-Host ("  ❌ {0,-10} NOT found" -f $Pretty)
        return $false
    }
}

$missing = @()

Write-Host "▶ Checking required tools..."
Write-Host ""

if (-not (Test-Tool -Name "cmake" -Pretty "cmake"))   { $missing += "cmake" }
if (-not (Test-Tool -Name "ctest" -Pretty "ctest"))   { $missing += "ctest" }
if (-not (Test-Tool -Name "python" -Pretty "python")) { $missing += "python" }
if (-not (Test-Tool -Name "doxygen" -Pretty "doxygen")) { $missing += "doxygen" }

# Coverage tools (opcionales si en Windows no usarás lcov)
if (-not (Test-Tool -Name "lcov" -Pretty "lcov"))     { $missing += "lcov (optional)" }
if (-not (Test-Tool -Name "genhtml" -Pretty "genhtml")) { $missing += "genhtml (optional)" }

# Compilador: cl (MSVC) o g++ o clang++
$hasCompiler = $false
if (Get-Command "cl.exe" -ErrorAction SilentlyContinue) {
    Write-Host ("  ✔ {0,-10} found (MSVC cl.exe)" -f "C++")
    $hasCompiler = $true
} elseif (Get-Command "g++" -ErrorAction SilentlyContinue) {
    Write-Host ("  ✔ {0,-10} found (g++)" -f "C++")
    $hasCompiler = $true
} elseif (Get-Command "clang++" -ErrorAction SilentlyContinue) {
    Write-Host ("  ✔ {0,-10} found (clang++)" -f "C++")
    $hasCompiler = $true
}

if (-not $hasCompiler) {
    Write-Host ("  ❌ {0,-10} NOT found" -f "C++")
    $missing += "C++ compiler (MSVC, g++ or clang++)"
}

Write-Host ""
if ($missing.Count -eq 0) {
    Write-Host "✅ All required tools seem to be installed." -ForegroundColor Green
} else {
    Write-Host "⚠ Missing tools / suggestions:" -ForegroundColor Yellow
    foreach ($m in $missing) {
        Write-Host "  - $m"
        if ($m -like "cmake") {
            Write-Host "    e.g. winget install Kitware.CMake  OR  choco install cmake"
        } elseif ($m -like "ctest") {
            Write-Host "    (ctest viene con CMake; instala cmake primero)"
        } elseif ($m -like "python") {
            Write-Host "    e.g. winget install Python.Python.3  OR  choco install python"
        } elseif ($m -like "doxygen") {
            Write-Host "    e.g. choco install doxygen.install"
        } elseif ($m -like "lcov*") {
            Write-Host "    (optional) You may need MSYS2 or a Windows port of lcov."
        } elseif ($m -like "genhtml*") {
            Write-Host "    (optional) Part of lcov."
        } elseif ($m -like "C++*") {
            Write-Host "    Install Visual Studio (Desktop development with C++)"
            Write-Host "    or MSYS2 (g++) or LLVM/Clang for Windows."
        }
        Write-Host ""
    }
}

# ---- Enable scripts (PowerShell side) ----
Write-Host "▶ Enabling scripts in scripts/ (PowerShell context)..."

# Levantar ExecutionPolicy solo para este proceso
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Mostrar scripts detectados
$scriptsDir = Join-Path $PSScriptRoot "."
$files = Get-ChildItem -Recurse $scriptsDir -Include *.ps1, *.sh -ErrorAction SilentlyContinue

foreach ($f in $files) {
    Write-Host ("  • {0}" -f $f.FullName)
}

# Si existe EnableScripts.sh, sugerir usarlo desde WSL/macOS/Linux
$enableSh = Join-Path $PSScriptRoot "EnableScripts.sh"
if (Test-Path $enableSh) {
    Write-Host ""
    Write-Host "ℹ If you run this repo inside WSL or Linux/macOS, you can execute:"
    Write-Host "   ./scripts/EnableScripts.sh"
}

Write-Host ""
Write-Host "Done. You can now run, for example:"
Write-Host "   pwsh scripts/run_tests.ps1"
Write-Host "   pwsh scripts/code_coverage.ps1   (si configuraste lcov en Windows)"
