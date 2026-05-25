# PowerShell profile fragment (`CookieMonster.profile.ps1`) Reference

Location: `CookieMonster.profile.ps1`.

Purpose: the interactive Cookie Monster functions and prompt override for PowerShell users.

Globals & storage

- Global variables track counters and state (e.g. `CookieEncounters`, `CookiesEaten`, `CookieRefusals`, etc.).
- Settings saved to: `~/.cookie_settings.json` (path in `$script:CookieSettingsPath`).

Key functions provided by the fragment

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

Notes & compatibility

- The fragment avoids PowerShell 7-only constructs and guards Windows-only APIs so it can be loaded on PowerShell Core (macOS/Linux) and Windows PowerShell 5.1.
- Non-interactive contexts (CI) skip printing startup messages.
