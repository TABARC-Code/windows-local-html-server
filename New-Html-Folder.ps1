# TABARC-Code
# Purpose: Create a starter HTML folder that is hard to mess up.
# Notes:
# - Creates index.html, style.css, assets/
# - Refuses to overwrite unless -Force

[CmdletBinding()]
param(
  [Parameter(Mandatory = $true)]
  [string]$Path,

  [switch]$Force,
  [switch]$OpenFolder
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-FileIfMissing {
  param([string]$FilePath, [string]$Content, [switch]$ForceWrite)
  if ((Test-Path -LiteralPath $FilePath) -and (-not $ForceWrite)) {
    Write-Host "Skip existing: $FilePath"
    return
  }
  $dir = Split-Path -Parent $FilePath
  if ($dir -and -not (Test-Path -LiteralPath $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
  }
  Set-Content -LiteralPath $FilePath -Value $Content -Encoding UTF8
  Write-Host "Wrote: $FilePath"
}

$full = (Resolve-Path -LiteralPath (New-Item -ItemType Directory -Force -Path $Path).FullName).Path
$assets = Join-Path $full "assets"
New-Item -ItemType Directory -Force -Path $assets | Out-Null

$index = @"
<!doctype html>
<html lang="en-GB">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>TABARC local site</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <main class="wrap">
    <h1>Local HTML server is running</h1>
    <p>If you can see this, you are serving the right folder. That puts you ahead of most people.</p>

    <section class="card">
      <h2>Edit me</h2>
      <p>Open <code>index.html</code> and change the content.</p>
      <p>Example asset: <a href="assets/example.svg">assets/example.svg</a></p>
    </section>

    <section class="card">
      <h2>Sanity check</h2>
      <p>Change this line, save, refresh the browser, confirm it changed.</p>
      <p>If it did not change, you are serving the wrong folder.</p>
    </section>
  </main>
</body>
</html>
"@

$css = @"
:root { color-scheme: light dark; }
body { font-family: system-ui, Segoe UI, Arial, sans-serif; margin: 0; padding: 0; }
.wrap { max-width: 900px; margin: 32px auto; padding: 0 16px; }
.card { border: 1px solid rgba(127,127,127,0.35); border-radius: 10px; padding: 16px; margin: 12px 0; }
code { font-family: ui-monospace, Consolas, monospace; }
"@

$svg = @"
<svg xmlns="http://www.w3.org/2000/svg" width="640" height="240">
  <rect width="100%" height="100%" fill="#111"/>
  <text x="24" y="90" fill="#fff" font-size="28" font-family="Segoe UI, Arial, sans-serif">
    TABARC local server asset
  </text>
  <text x="24" y="140" fill="#bbb" font-size="16" font-family="Consolas, monospace">
    assets/example.svg
  </text>
</svg>
"@

Write-FileIfMissing -FilePath (Join-Path $full "index.html") -Content $index -ForceWrite:$Force
Write-FileIfMissing -FilePath (Join-Path $full "style.css") -Content $css -ForceWrite:$Force
Write-FileIfMissing -FilePath (Join-Path $assets "example.svg") -Content $svg -ForceWrite:$Force

if ($OpenFolder) { Start-Process explorer.exe $full }

Write-Host "Done: $full"
