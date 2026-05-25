# PowerShell installer (`install.ps1`) Reference

Location: `install.ps1` (repo root).

Purpose: install the `CookieMonster.profile.ps1` fragment into the user's PowerShell profile, backing up existing profiles and injecting a marker block that dot-sources the fragment.

Parameters (top-level)

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

Key functions exported by `install.ps1` (internal helpers)

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

Notes

- The installer uses a marker block delineated by `# >>> cookie-monster >>>` and `# <<< cookie-monster <<<` to safely replace just the injected fragment block.
- Backups: if a profile exists, the installer copies it to `<profile>.bak` before making modifications (unless `-Force` is used to overwrite).
