# TABARC-Code
# Purpose: Install or remove a Scheduled Task to run the local HTML server at logon.

[CmdletBinding()]
param(
  [switch]$Install,
  [switch]$Uninstall,

  [string]$TaskName = "TABARC Local HTML Server",
  [string]$Path = "",
  [int]$Port = 8000,
  [string]$Bind = "127.0.0.1",
  [switch]$AutoPort,
  [switch]$OpenBrowser,
  [switch]$RunHighest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m) { Write-Error $m; exit 1 }

if (-not $Install -and -not $Uninstall) { Fail "Specify -Install or -Uninstall." }

if ($Uninstall) {
  schtasks /delete /tn $TaskName /f | Out-Null
  Write-Host "Removed task: $TaskName"
  exit 0
}

if (-not $Path) { Fail "Path is required for -Install." }

$scriptPath = Join-Path $PSScriptRoot "Start-LocalHtmlServer.ps1"
if (-not (Test-Path -LiteralPath $scriptPath)) { Fail "Start script not found: $scriptPath" }

$ps = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"

$args = @(
  '-NoProfile',
  '-ExecutionPolicy', 'Bypass',
  '-File', ('"{0}"' -f $scriptPath),
  '-Path', ('"{0}"' -f $Path),
  '-Port', $Port,
  '-Bind', $Bind,
  '-WritePid'
)

if ($AutoPort) { $args += '-AutoPort' }
if ($OpenBrowser) { $args += '-OpenBrowser' }

$tr = '"' + $ps + '" ' + ($args -join ' ')
$rl = if ($RunHighest) { "highest" } else { "limited" }

schtasks /create /tn $TaskName /tr $tr /sc onlogon /rl $rl /f | Out-Null
Write-Host "Installed task: $TaskName"
Write-Host "Command: $tr"
