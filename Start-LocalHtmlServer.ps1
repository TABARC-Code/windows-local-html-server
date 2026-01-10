# TABARC-Code
# Purpose: Start a local static HTTP server for a directory using Python.
# Notes:
# - Wrapper around python -m http.server
# - Defaults: localhost only, port 8000, PID file enabled
# - Writes a PID file for the Python server process (not this PowerShell process)

[CmdletBinding()]
param(
  [string]$Path = (Get-Location).Path,
  [int]$Port = 8000,
  [switch]$AutoPort,
  [string]$Bind = "127.0.0.1",
  [switch]$OpenBrowser,
  [string]$OpenFile = "",
  [string]$Config = "",
  [switch]$Quiet,
  [switch]$WritePid,
  [string]$PidFileName = ".local-html-server.pid",
  [switch]$PreferDirectoryFlag,
  [switch]$ForceRestart
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m) { Write-Error $m; exit 1 }

function Load-ConfigFile {
  param([string]$PathToConfig)
  if (-not $PathToConfig) { return $null }
  if (-not (Test-Path -LiteralPath $PathToConfig)) { Fail "Config not found: $PathToConfig" }
  try { Get-Content -Raw -LiteralPath $PathToConfig | ConvertFrom-Json } catch { Fail "Config parse failed: $($_.Exception.Message)"; return $null }
}

function Test-PortFree {
  param([int]$PortToTest, [string]$BindAddr)
  try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Parse($BindAddr), $PortToTest)
    $listener.Start()
    $listener.Stop()
    $true
  } catch { $false }
}

function Find-FreePort {
  param([int]$StartPort, [string]$BindAddr, [int]$MaxTries = 50)
  $p = $StartPort
  for ($i = 0; $i -lt $MaxTries; $i++) {
    if (Test-PortFree -PortToTest $p -BindAddr $BindAddr) { return $p }
    $p++
  }
  Fail "Could not find a free port starting at $StartPort (tries=$MaxTries)."
  return $StartPort
}

function Get-LocalIPv4Hint {
  try {
    $ips = Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
      Where-Object { $_.IPAddress -notlike "169.254.*" -and $_.IPAddress -ne "127.0.0.1" } |
      Select-Object -ExpandProperty IPAddress
    $ips | Select-Object -First 1
  } catch { $null }
}

function ParamWasSet([string]$name) { $PSBoundParameters.ContainsKey($name) }

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
  Fail "Python not found on PATH. Install Python 3 and try again."
}

# Defaults first, then config, then explicit CLI parameters override config
$cfg = Load-ConfigFile -PathToConfig $Config

if ($cfg) {
  if ($cfg.path -and -not (ParamWasSet "Path")) { $Path = [string]$cfg.path }
  if ($cfg.port -and -not (ParamWasSet "Port")) { $Port = [int]$cfg.port }
  if ($null -ne $cfg.autoPort -and -not (ParamWasSet "AutoPort")) { $AutoPort = [bool]$cfg.autoPort }
  if ($cfg.bind -and -not (ParamWasSet "Bind")) { $Bind = [string]$cfg.bind }
  if ($null -ne $cfg.openBrowser -and -not (ParamWasSet "OpenBrowser")) { $OpenBrowser = [bool]$cfg.openBrowser }
  if ($cfg.openFile -and -not (ParamWasSet "OpenFile")) { $OpenFile = [string]$cfg.openFile }
  if ($null -ne $cfg.quiet -and -not (ParamWasSet "Quiet")) { $Quiet = [bool]$cfg.quiet }
  if ($null -ne $cfg.writePid -and -not (ParamWasSet "WritePid")) { $WritePid = [bool]$cfg.writePid }
  if ($cfg.pidFileName -and -not (ParamWasSet "PidFileName")) { $PidFileName = [string]$cfg.pidFileName }
  if ($null -ne $cfg.preferDirectoryFlag -and -not (ParamWasSet "PreferDirectoryFlag")) { $PreferDirectoryFlag = [bool]$cfg.preferDirectoryFlag }
}

# Default to writing PID unless explicitly disabled
if (-not (ParamWasSet "WritePid") -and (-not $cfg)) { $WritePid = $true }
if (-not (ParamWasSet "WritePid") -and $cfg -and $null -eq $cfg.writePid) { $WritePid = $true }

if (-not (Test-Path -LiteralPath $Path)) { Fail "Path does not exist: $Path" }
$fullPath = (Resolve-Path -LiteralPath $Path).Path

$pidFile = Join-Path $fullPath $PidFileName

if (Test-Path -LiteralPath $pidFile) {
  $oldPid = (Get-Content -LiteralPath $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
  $oldProc = $null
  if ($oldPid -match "^\d+$") { $oldProc = Get-Process -Id ([int]$oldPid) -ErrorAction SilentlyContinue }

  if ($oldProc) {
    if (-not $ForceRestart) {
      Fail "PID file exists and process is running (PID $oldPid). Use Stop-LocalHtmlServer.ps1 or pass -ForceRestart."
    } else {
      try { Stop-Process -Id ([int]$oldPid) -ErrorAction SilentlyContinue } catch {}
      try { Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue } catch {}
    }
  } else {
    # stale pid file
    try { Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue } catch {}
  }
}

if ($AutoPort) {
  $Port = Find-FreePort -StartPort $Port -BindAddr $Bind
} else {
  if (-not (Test-PortFree -PortToTest $Port -BindAddr $Bind)) {
    Fail "Port $Port is not available on $Bind. Use -AutoPort or choose another port."
  }
}

$baseUrl = "http://$Bind`:$Port"
$url = $baseUrl
if ($OpenFile) {
  $trim = $OpenFile.TrimStart("\","/")
  $url = "$baseUrl/$trim"
}

# Build args for python http.server.
# Prefer --directory when requested (Python 3.7+). Fallback is starting in that directory.
$pyArgs = @("-m","http.server",$Port.ToString(),"--bind",$Bind)
$useDirFlag = $PreferDirectoryFlag.IsPresent -or ($cfg -and $cfg.preferDirectoryFlag)

if ($useDirFlag) {
  $pyArgs += @("--directory", $fullPath)
  $workingDir = (Get-Location).Path
} else {
  $workingDir = $fullPath
}

if (-not $Quiet) {
  Write-Host "Serving directory: $fullPath"
  Write-Host "Bind: $Bind"
  Write-Host "Port: $Port"
  Write-Host "URL: $url"
  if ($Bind -eq "0.0.0.0") {
    $hint = Get-LocalIPv4Hint
    if ($hint) { Write-Host "LAN hint: http://$hint`:$Port" }
  }
  if ($WritePid) { Write-Host "PID file: $pidFile" }
  Write-Host "Press Ctrl+C to stop"
}

if ($OpenBrowser) { Start-Process $url }

# Start Python as a child process so the PID file points to the actual server.
$proc = Start-Process -FilePath "python" -ArgumentList $pyArgs -WorkingDirectory $workingDir -PassThru

if ($WritePid) {
  Set-Content -LiteralPath $pidFile -Value $proc.Id -Encoding ASCII
}

# Wait for Python to exit, then clean up PID file if it still points to this process.
try {
  $proc.WaitForExit()
} finally {
  if ($WritePid -and (Test-Path -LiteralPath $pidFile)) {
    try {
      $still = (Get-Content -LiteralPath $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1).Trim()
      if ($still -eq $proc.Id.ToString()) { Remove-Item -LiteralPath $pidFile -Force -ErrorAction SilentlyContinue }
    } catch {}
  }
}
