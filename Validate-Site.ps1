# TABARC-Code
# Purpose: Sanity check a site folder so you stop serving the wrong directory.

[CmdletBinding()]
param(
  [string]$Path = (Get-Location).Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Warn([string]$m) { Write-Host "WARN: $m" }
function Fail([string]$m) { Write-Error $m; exit 1 }

if (-not (Test-Path -LiteralPath $Path)) { Fail "Path does not exist: $Path" }
$full = (Resolve-Path -LiteralPath $Path).Path

$index = Join-Path $full "index.html"
if (-not (Test-Path -LiteralPath $index)) {
  Warn "No index.html found in: $full"
  Warn "If you start the server here, you will get directory listings or 404s depending on what you click."
} else {
  Write-Host "OK: index.html exists"
}

$css = Join-Path $full "style.css"
if (-not (Test-Path -LiteralPath $css)) { Warn "No style.css found (not fatal, just check your links)" }

$pid = Join-Path $full ".local-html-server.pid"
if (Test-Path -LiteralPath $pid) { Warn "PID file exists. If the server is not running, stop script will clean it." }

Write-Host "Checked: $full"
