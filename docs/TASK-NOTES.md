# Scheduled Task notes

The task runs at user logon.

You are responsible for:
- choosing a safe bind address
- choosing a folder safe to expose (especially with 0.0.0.0)
- ensuring Python is available on PATH in your user environment

The task calls:
`powershell.exe -File Start-LocalHtmlServer.ps1 ...`

For reliability:
- bind to 127.0.0.1
- fixed port
- no LAN exposure
- do not auto-open the browser unless you really want it every logon

If you install multiple tasks, name them differently.
Windows will not babysit your choices.
