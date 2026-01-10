# TABARC-Code
# Purpose: Open a folder in VS Code if available, otherwise fall back to Notepad.

[CmdletBinding()]
param(
  [string]$Path = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path)) { Write-Error "Path does not exist: $Path"; exit 1 }
$full = (Resolve-Path -LiteralPath $Path).Path

$code = Get-Command code -ErrorAction SilentlyContinue
if ($code) {
  Start-Process -FilePath $code.Source -ArgumentList @($full)
  exit 0
}

$index = Join-Path $full "index.html"
if (Test-Path -LiteralPath $index) {
  Start-Process notepad.exe $index
} else {
  Start-Process explorer.exe $full
}
