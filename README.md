# windows-local-html-server
A Windows-first wrapper for running a local static HTML server using Python, with the quality-of-life bits people always end up rebuilding: auto port, bind address, config file, open browser, scaffold a site folder, scheduled task, firewall helper, and a clean stop mechanism.

# windows-local-html-server

A Windows-first wrapper for running a local static HTML server using Python, with the quality-of-life bits people always end up rebuilding:
auto port, bind address, config file, open browser, scaffold a site folder, scheduled task, firewall helper, and a clean stop mechanism.

Author: TABARC-Code  
Plugin URI: https://github.com/TABARC-Code/

## What this repo is

### Core scripts

- `New-Html-Folder.ps1`  
  Creates a starter site folder with `index.html`, `style.css`, and `assets/` (with a tiny example asset).

- `Start-LocalHtmlServer.ps1`  
  Starts a static server using `python -m http.server` with sane parameters and optional config file.

- `Stop-LocalHtmlServer.ps1`  
  Stops a server started by this repo using a PID file (no “which console window was that” game).

### Ops scripts

- `Install-LocalHtmlServerTask.ps1`  
  Installs or removes a Scheduled Task to start the server at logon.

- `Firewall-LocalHtmlServer.ps1`  
  Optional firewall rule helper for LAN access when binding to `0.0.0.0`.

Convenience

- `Serve-Here.ps1` and `Serve-Here.cmd`  
  Serve the current folder quickly.

- `Open-In-Editor.ps1`  
  Opens a folder in VS Code if available, otherwise Notepad.

- `Validate-Site.ps1`  
  Sanity checks a site folder (index exists, common mistakes).

## Requirements

- Python 3
- `python` available on PATH

### Check:

```powershell
python --version
Quick start
Create a starter site:

powershell
Copy code
.\New-Html-Folder.ps1 -Path .\site -OpenFolder
Validate it:

powershell
Copy code
.\Validate-Site.ps1 -Path .\site
Serve it locally:

powershell
Copy code
.\Start-LocalHtmlServer.ps1 -Path .\site -OpenBrowser -AutoPort
Stop it later:

powershell
Copy code
.\Stop-LocalHtmlServer.ps1 -Path .\site
LAN access (optional)
If you want to view from another device on the same network:

powershell
Copy code
.\Start-LocalHtmlServer.ps1 -Path .\site -Bind 0.0.0.0 -AutoPort
Read docs/SECURITY-NOTES.md first.

You may also need a firewall rule (Private profile):

powershell
Copy code
.\Firewall-LocalHtmlServer.ps1 -Allow -Port 8000
Scheduled Task (optional)
Install a task to start serving a folder at logon:

powershell
Copy code
.\Install-LocalHtmlServerTask.ps1 -Install -Path "C:\Sites\demo" -Port 8000 -Bind 127.0.0.1 -OpenBrowser
Remove it:

powershell
Copy code
.\Install-LocalHtmlServerTask.ps1 -Uninstall
See docs/TASK-NOTES.md.

Configuration
You can use config.json to store defaults and override them.
Precedence is:

defaults < config file < explicit command-line parameters

Example config: config.example.json
