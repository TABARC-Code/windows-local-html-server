## docs/idiots-guide.md

```markdown
# Idiot’s guide

Goal: make a folder with an `index.html`, then serve it.

## Step 1: create a site folder

From the repo directory:

```powershell
.\New-Html-Folder.ps1 -Path .\site -OpenFolder
Edit site\index.html.

If you want to open it in something better than Notepad:

powershell
Copy code
.\Open-In-Editor.ps1 -Path .\site
Step 2: sanity check (optional but smart)
powershell
Copy code
.\Validate-Site.ps1 -Path .\site
If it complains, fix that first. Most “server issues” are actually “wrong folder” issues.

Step 3: serve it
powershell
Copy code
.\Start-LocalHtmlServer.ps1 -Path .\site -AutoPort -OpenBrowser
Stop with Ctrl+C.

If you want to stop it later without remembering which console:
this repo writes a PID file by default.

Stop it:

powershell
Copy code
.\Stop-LocalHtmlServer.ps1 -Path .\site
Step 4: serving the folder you are currently in
From any folder:

powershell
Copy code
powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Path\To\Repo\Serve-Here.ps1" -AutoPort -OpenBrowser
Or double-click Serve-Here.cmd to serve the repo folder itself.

Common failures
Python missing:

powershell
Copy code
python --version
Port already taken: use -AutoPort.

LAN access does not work:

you probably bound to 127.0.0.1

or the bloody firewall is blocking it

or you are on a public network profile and the rule is Private-only

Enjoy the rare win:
DPI does not matter here. This is not pixel automation.
