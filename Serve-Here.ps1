# TABARC-Code
# Purpose: Serve the current directory quickly.

[CmdletBinding()]
param(
  [int]$Port = 8000,
  [switch]$AutoPort,
  [string]$Bind = "127.0.0.1",
  [switch]$OpenBrowser,
  [string]$OpenFile = ""
)

$here = (Get-Location).Path
& (Join-Path $PSScriptRoot "Start-LocalHtmlServer.ps1") -Path $here -Port $Port -AutoPort:$AutoPort -Bind $Bind -OpenBrowser:$OpenBrowser -OpenFile $OpenFile
