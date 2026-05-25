# Commands & Functions Reference

This document describes the user-facing commands, installer flags, and exported functions in both native and PowerShell variants of Cookie Monster.

Table of contents
- Native (POSIX) CLI: `cookie`
- Native installer: `install.sh` (root) and platform installers
- Windows native installer: `platforms/windows/install.bat` and `cookie.bat`
- PowerShell installer: `install.ps1` (parameters & functions)
- PowerShell profile fragment: `CookieMonster.profile.ps1` (functions & globals)
- Developer notes: testing, packaging, CI

---

## Native (POSIX) CLI: `cookie`

Location: `cookie` (repo root), `platforms/linux/cookie`, `platforms/macos/cookie`.

Purpose: a lightweight POSIX shell CLI that provides the interactive Cookie Monster experience without PowerShell.

Usage:

```
cookie [COMMAND]
```

Commands:
- --help, -h, help
  - Show help text and available commands.
- --on
  - Enable random encounters (persisted to data directory).
- --off
  - Disable random encounters.
- --toggle
  - Flip enabled/disabled state.
- --scoreboard
  - Print counters and achievements stored in the XDG data state file.
- --bake
  - Launch a small interactive baking flow to create cookies and update inventory.
- --settings
  - Open settings menu to change encounter chance, toggle beep sounds, rename the monster, or reset scoreboards.
- --repo
  - Print the default repository that the installer uses to fetch releases (useful for debugging).

Behavior & storage:
- Data: `${XDG_DATA_HOME:-~/.local/share}/cookie-monster/state.env` — persistent state (numbers and flags).
- Config: `${XDG_CONFIG_HOME:-~/.config}/cookie-monster/settings.env` — user-configured options (beeps, encounter chance, monster name).
- Cache: `${XDG_CACHE_HOME:-~/.cache}/cookie-monster` — release ZIP downloads and a stage area used by the installer.

Design notes:
- The CLI avoids external dependencies where possible. It uses `curl` to download releases and falls back to `tar` or Python's `zipfile` module to extract archives.
- Interactive features (spinner, ASCII art) are best-effort and no-ops in non-TTY contexts (so CI can call `cookie --help`).

Examples:

Show help:

```sh
./cookie --help
```

Enable encounters:

```sh
./cookie --on
```


---

## Native installer: `install.sh` (root)

Location: `install.sh` (repo root). Platform-specific copies exist in `platforms/*/install.sh`.

Purpose: install files into XDG-friendly directories and create a shim at `~/.local/bin/cookie`.

Flags:
- --update-now
  - Download the latest release ZIP into the cache (no install). Writes the zip into `${XDG_CACHE_HOME:-~/.cache}/cookie-monster/downloads`.
- --auto-install
  - Download the latest release and install it into `${XDG_DATA_HOME:-~/.local/share}/cookie-monster`, creating a shim in `${HOME}/.local/bin`.
- --install-local
  - Install from the current repo copy (useful for development). Copies repository files into the install location and creates a shim.
- --help
  - Show usage text.

Extraction fallbacks (in order of preference):
1. `unzip` (preferred)
2. `tar -xf` (if available and supports zip)
3. `python3` using the `zipfile` module
4. `python` (2.x/3.x) using the `zipfile` module

If none exist, the installer errors with a helpful message and exit code.

Notes:
- The installer uses `curl` to download the release; if `curl` is missing users should install it or use the `check-deps.sh` helper.
- After installation, the shim prints a warning if `${HOME}/.local/bin` is not in the user's PATH.


---

## Windows native installer and shim

Files:
- `platforms/windows/install.bat` — batch installer that downloads the release and extracts to `%LOCALAPPDATA%\cookie-monster`.
- `platforms/windows/cookie.bat` — shim that tries to run the installed POSIX `cookie` script with `bash` (Git Bash or WSL) if present.

Behavior & fallbacks:
- Download: `curl` first; if that fails the script invokes PowerShell's `Invoke-WebRequest` as a fallback.
- Extract: `tar -xf` first; if that fails it calls PowerShell's `Expand-Archive` as a fallback.
- If neither path is available the script exits with an error and prints guidance.

Notes:
- The Windows batch installer intentionally avoids PowerShell as the primary runtime but uses it as a robust fallback because many Windows systems have PowerShell even when they lack `curl`/`tar`.


---

## PowerShell installer: `install.ps1`

Location: `install.ps1` (repo root).

Purpose: install the `CookieMonster.profile.ps1` fragment into the user's PowerShell profile, backing up existing profiles and injecting a marker block that dot-sources the fragment.

Parameters (top-level):
- `-SourcePath` (string)
  - Path to the source fragment (defaults to `CookieMonster.profile.ps1` in the repo root).
- `-TargetProfilePath` (string)
  - Manually specify the target PowerShell profile file to update.
- `-TargetFragmentPath` (string)
  - Manually specify where to copy the fragment file.
- `-Repository` (string)
  - GitHub repo (default `ilim-cell/cookie-monster`) used by the update flow.
- `-CachePath` (string)
  - Where releases are cached (`~/.cache/cookie-monster` by default).
- `-UpdateNow` (switch)
  - Download the latest release ZIP into the cache and exit.
- `-AutoInstall` (switch)
  - Download and install the latest release to the user's PowerShell profile.
- `-Force` (switch)
  - Force re-download and overwrite backups where applicable.

Key functions exported by `install.ps1` (internal helpers):
- `Get-CookieMonsterTargetProfilePath` — Resolve the current user profile path with fallbacks for `$PROFILE.CurrentUserCurrentHost` and a default path.
- `Get-CookieMonsterTargetFragmentPath` — Compute the destination fragment path (sibling to the resolved profile).
- `Get-CookieMonsterCachePath` — Resolve cache location (defaults to `~/.cache/cookie-monster`).
- `New-CookieMonsterDirectory` — Safe directory creation helper.
- `Test-CookieMonsterInteractiveHost` — Detect interactive host for spinner/art.
- `Show-CookieMonsterArt` — ASCII banner renderer (best-effort across hosts).
- `Show-CookieMonsterSpinner` — Spinner/UX helper (no-op in non-interactive hosts).
- `Show-CookieMonsterInstallerMenu` — Present interactive installer choices (InstallLocal/UpdateNow/AutoInstall/Exit).
- `Get-CookieMonsterLatestRelease` — Call GitHub Releases API to get the latest release object.
- `Save-CookieMonsterReleaseZip` — Download and cache `cookie-monster.zip` asset.
- `Expand-CookieMonsterReleaseZip` — Expand the ZIP to a staging directory (PowerShell uses `Expand-Archive`).
- `Install-CookieMonsterProfileFragment` — Idempotently inject or replace the marker block in the target profile and copy the fragment file into the user's profile directory.
- `Write-CookieMonsterBanner` — Simple message helper.

Notes:
- The installer uses a marker block delineated by `# >>> cookie-monster >>>` and `# <<< cookie-monster <<<` to safely replace just the injected fragment block.
- Backups: if a profile exists, the installer copies it to `<profile>.bak` before making modifications (unless `-Force` is used to overwrite).


---

## PowerShell profile fragment: `CookieMonster.profile.ps1`

Location: `CookieMonster.profile.ps1`.

Purpose: the interactive Cookie Monster functions and prompt override for PowerShell users.

Globals & storage:
- Global variables track counters and state (e.g. `CookieEncounters`, `CookiesEaten`, `CookieRefusals`, etc.).
- Settings saved to: `~/.cookie_settings.json` (path in `$script:CookieSettingsPath`).

Key functions provided by the fragment:
- `Save-CookieSettings` — Persist the `CookieSettings` ordered hashtable to JSON on disk.
- `Write-CookieBeep` — Attempt a beep via `[Console]::Beep()` on Windows when beeps enabled.
- `Read-CookiePrompt` — Read input with optional timeout; provides a timeout token value when timed out.
- `Start-BakingAnimation` — Interactive cookie baking flow (updates baked counters).
- `Show-GlitchScreenAnimation` — Best-effort glitch animation; guarded on Windows for console color support.
- `Show-CookieScoreboard` — Print counters and achievements.
- `Show-CookieSettingsMenu` — Interactive settings menu (change encounter chance, toggle beeps, rename monster, reset scoreboards).
- `Show-CookieHelp` — Print help for the `cookie` command.
- `Start-CookieMonster` — Main interactive encounter flow (timed input, accepts cookie/feed/trick/magic/glitch/etc.).
- `cookie` (function) — CLI entrypoint for PowerShell users; dispatches on arguments (`--on/--off/--toggle/--bake/--scoreboard/--settings/--help`), otherwise launches `Start-CookieMonster`.
- `prompt` override — Wraps the original `prompt` function and triggers random encounters based on `CookieSettings.EncounterChance`.

Notes & compatibility:
- The fragment avoids PowerShell 7-only constructs and guards Windows-only APIs so it can be loaded on PowerShell Core (macOS/Linux) and Windows PowerShell 5.1.
- Non-interactive contexts (CI) skip printing startup messages.


---

## Developer notes

Testing locally:
- Run the dependency check:

```sh
./check-deps.sh
```

- Run non-interactive smoke tests:

```sh
# Native CLI
chmod +x cookie
./cookie --help

# Native installer (non-interactive)
chmod +x install.sh
./install.sh --update-now

# PowerShell parsing tests (on machines with pwsh or powershell.exe)
# Use the built-in parser in CI scripts; e.g. parse files with System.Management.Automation.Language.Parser
```

CI and packaging:
- GitHub Actions validate PowerShell files across Windows/macOS/Linux.
- Release workflow packages both PowerShell and native artifacts into `dist/cookie-monster.zip` (includes `cookie`, `install.sh`, and `platforms/*`).

Contributing:
- Add new commands by editing the `cookie` CLI and updating `docs/COMMANDS.md`.
- If you add platform-specific binaries or scripts, add them under `platforms/<os>` and update `release.yml` packaging accordingly.


---

If you'd like, I can also convert this document into separate reference pages (one per file) and generate a small index `docs/index.md` for a built docs site.
