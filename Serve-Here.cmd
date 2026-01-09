@echo off
setlocal

REM TABARC-Code
REM Double-click convenience: serve the current directory with auto port and open browser.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Serve-Here.ps1" -AutoPort -OpenBrowser
