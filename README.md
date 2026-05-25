# cookie-monster

Cookie Monster, now with an installer that can update itself without dragging the user through a cave full of shell goblins.

## What’s included

- `CookieMonster.profile.ps1` — the extracted profile fragment
- `install.ps1` — installs locally or updates from the latest GitHub Release
- `.github/workflows/ci.yml` — validates the PowerShell files on Windows, Linux, and macOS
- `.github/workflows/release.yml` — packages the fragment into a release ZIP on tags
- `.github/ISSUE_TEMPLATE/*` — bug and feature request forms

## Install and update

Run the installer from the repo root with PowerShell 7:

`pwsh -File ./install.ps1`

That will:

- copy `CookieMonster.profile.ps1` into your current PowerShell profile directory
- back up your profile to `Microsoft.PowerShell_profile.ps1.bak` if one already exists
- add or replace a dot-source block so the fragment loads automatically

### Update now

`pwsh -File ./install.ps1 -UpdateNow`

This downloads the latest release ZIP into a hidden cache at `~/.cache/cookie-monster` and stages the fragment for installation.

### Automatically install

`pwsh -File ./install.ps1 -AutoInstall`

This downloads the latest release if needed, extracts the fragment from the cache, and installs it immediately.

## Use it

Once installed, these commands are available:

- `cookie` — launch the Cookie Monster
- `cookie --on` / `cookie --off` / `cookie --toggle` — control random encounters
- `cookie --bake` — bake cookies
- `cookie --scoreboard` — inspect counters
- `cookie --settings` — adjust preferences
- `cookie --help` — show the command list

Native macOS / Linux install

If you prefer a native POSIX installer (no PowerShell required), use the provided shell installer:

```
./install.sh --auto-install
```

This installs the native `cookie` CLI into your XDG data directory (default: `~/.local/share/cookie-monster`) and creates a shim in `~/.local/bin` if available.

Directories used by the native installer

- Data: ${XDG_DATA_HOME:-~/.local/share}/cookie-monster
- Config (settings): ${XDG_CONFIG_HOME:-~/.config}/cookie-monster
- Cache (downloads & stage): ${XDG_CACHE_HOME:-~/.cache}/cookie-monster

If you don't have PowerShell on your macOS or Linux machine, the native installer provides a fully POSIX-compatible CLI implemented in `cookie` and managed by `install.sh`.

See `docs/INSTALL.md` for per-platform installation instructions, troubleshooting, and packaging notes.

## Cross-platform notes

- The installer targets PowerShell 7 on Windows, macOS, and Linux.
- It was also tested on Windows PowerShell 5.1 for the local install path.
- GitHub Actions now validates the repo on all three operating systems.
- The profile fragment keeps the fun bits, but gracefully degrades where host-specific console features are unavailable.

## Release notes

Tag a commit with a version like `v1.0.0` to package the fragment, installer, and README into `cookie-monster.zip`.
