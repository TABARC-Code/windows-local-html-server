## docs/SECURITY-NOTES.md

```markdown
# Security notes

This uses Python’s built-in development server.
It is not a production server.

## Default is safe: localhost only

Binding to `127.0.0.1` means only your machine can access it.
This is the default.

## 0.0.0.0 exposes your folder to the network

Binding to `0.0.0.0` means other devices on your network can browse your served folder. its simple and stupid

Do not serve:
- your profile folder
- your downloads folder
- anything with tokens, keys, private docs

Create a clean site folder and serve only that.

## Directory listings

Python’s simple server lists directories.
If you do not like that, do not serve folders containing anything you would not show.

## Firewall prompts

If you bind to `0.0.0.0`, Windows may prompt for firewall access.
If you do not understand the prompt, do not click Allow.
Use `Firewall-LocalHtmlServer.ps1` instead so you can reverse it cleanly.
