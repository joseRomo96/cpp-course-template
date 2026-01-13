param(
    [string]$ScriptsRoot = "scripts"
)

if (-not (Test-Path $ScriptsRoot)) {
    Write-Host "⚠ No scripts directory found at '$ScriptsRoot'."
    exit 1
}

Write-Host "▶ Enabling scripts inside '$ScriptsRoot'..."

# Habilitar ExecutionPolicy solo para este proceso
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Obtener scripts
$files = Get-ChildItem -Recurse $ScriptsRoot -Include *.sh, *.ps1

foreach ($file in $files) {
    Write-Host "  ✔ Script detected: $($file.FullName)"
}

Write-Host "✔ Scripts are now enabled (PowerShell ExecutionPolicy = Bypass in this process)."
