# TABARC-Code
# Purpose: Optional firewall helper for LAN serving.
# Notes:
# - Only needed if you bind to 0.0.0.0 and want other devices to connect.
# - Requires Administrator privileges.

[CmdletBinding()]
param(
  [switch]$Allow,
  [switch]$Remove,
  [int]$Port = 8000,
  [string]$RuleName = "TABARC Local HTML Server"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Fail([string]$m) { Write-Error $m; exit 1 }

function Assert-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  $p = New-Object Security.Principal.WindowsPrincipal($id)
  if (-not $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Fail "Administrator privileges required."
  }
}

if (-not $Allow -and -not $Remove) { Fail "Specify -Allow or -Remove." }
Assert-Admin

$hasNetSecurity = $null -ne (Get-Command New-NetFirewallRule -ErrorAction SilentlyContinue)

if ($Remove) {
  if ($hasNetSecurity) {
    Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
  } else {
    netsh advfirewall firewall delete rule name="$RuleName" protocol=TCP localport=$Port | Out-Null
  }
  Write-Host "Removed firewall rule: $RuleName"
  exit 0
}

if ($hasNetSecurity) {
  New-NetFirewallRule -DisplayName $RuleName -Direction Inbound -Action Allow -Protocol TCP -LocalPort $Port -Profile Private | Out-Null
} else {
  netsh advfirewall firewall add rule name="$RuleName" dir=in action=allow protocol=TCP localport=$Port profile=private | Out-Null
}
Write-Host "Added firewall rule: $RuleName (TCP $Port, Private profile)"
