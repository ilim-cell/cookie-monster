# Native CLI (`cookie`) Reference

Location: `cookie` (repo root), `platforms/linux/cookie`, `platforms/macos/cookie`.

Purpose: a lightweight POSIX shell CLI that provides the interactive Cookie Monster experience without PowerShell.

Usage:

```
cookie [COMMAND]
```

Commands

- `--help`, `-h`, `help`
  - Show help text and available commands.
- `--on`
  - Enable random encounters (persisted to data directory).
- `--off`
  - Disable random encounters.
- `--toggle`
  - Flip enabled/disabled state.
- `--scoreboard`
  - Print counters and achievements stored in the XDG data state file.
- `--bake`
  - Launch a small interactive baking flow to create cookies and update inventory.
- `--settings`
  - Open settings menu to change encounter chance, toggle beep sounds, rename the monster, or reset scoreboards.
- `--repo`
  - Print the default repository that the installer uses to fetch releases (useful for debugging).

Behavior & storage

- Data: `${XDG_DATA_HOME:-~/.local/share}/cookie-monster/state.env` — persistent state (numbers and flags).
- Config: `${XDG_CONFIG_HOME:-~/.config}/cookie-monster/settings.env` — user-configured options (beeps, encounter chance, monster name).
- Cache: `${XDG_CACHE_HOME:-~/.cache}/cookie-monster` — release ZIP downloads and a stage area used by the installer.

Design notes

- The CLI avoids external dependencies where possible. It uses `curl` to download releases and falls back to `tar` or Python's `zipfile` module to extract archives.
- Interactive features (spinner, ASCII art) are best-effort and no-ops in non-TTY contexts (so CI can call `cookie --help`).

Examples

Show help:

```sh
./cookie --help
```

Enable encounters:

```sh
./cookie --on
```
