# TABARC-Code
# Purpose: Stop a server started by Start-LocalHtmlServer.ps1 using its PID file.

[CmdletBinding()]
param(
  [string]$Path = (Get-Location).Path,
  [string]$PidFileName = ".local-html-server.pid",
  [switch]$Force
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m) { Write-Error $m; exit 1 }

if (-not (Test-Path -LiteralPath $Path)) { Fail "Path does not exist: $Path" }
$fullPath = (Resolve-Path -LiteralPath $Path).Path
$pidFile = Join-Path $fullPath $PidFileName

if (-not (Test-Path -LiteralPath $pidFile)) {
  Fail "PID file not found: $pidFile"
}

$pidText = (Get-Content -LiteralPath $pidFile -ErrorAction Stop | Select-Object -First 1).Trim()
if (-not $pidText -or -not ($pidText -match "^\d+$")) { Fail "PID file invalid: $pidFile" }

$pid = [int]$pidText
$p = Get-Process -Id $pid -ErrorAction SilentlyContinue

if (-not $p) {
  try { Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue } catch {}
  Fail "Process $pid not found. Cleaned stale PID file."
}

try {
  if ($Force) { Stop-Process -Id $pid -Force } else { Stop-Process -Id $pid }
  Write-Host "Stopped server PID $pid"
} finally {
  try { Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue } catch {}
}
