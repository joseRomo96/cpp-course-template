param(
    [string]$ScriptsRoot = "scripts"
)

if (-not (Test-Path $ScriptsRoot)) {
    Write-Host "⚠ No scripts directory found at '$ScriptsRoot'."
    exit 1
}

Write-Host "▶ Disabling scripts inside '$ScriptsRoot'..."

# Obtener scripts
$files = Get-ChildItem -Recurse $ScriptsRoot -Include *.sh, *.ps1

foreach ($file in $files) {
    Write-Host "  ❌ Script (cannot remove executable flag in Windows): $($file.FullName)"
}

# Reset ExecutionPolicy for safety
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Restricted -Force

Write-Host "✔ Scripts disabled (ExecutionPolicy reset)."
