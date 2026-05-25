# Installation (native cross-platform)

This project supports both PowerShell and native installers for each OS. The native installers are intentionally dependency-light and use standard OS-provided tools when possible.

## Linux / macOS (POSIX)

- Native CLI: `cookie` (located at `cookie` in repo root and `platforms/{linux,macos}/cookie`).
- Installer: `install.sh` (root) or `platforms/<os>/install.sh`.
- Default install locations (XDG):
  - Data: ${XDG_DATA_HOME:-~/.local/share}/cookie-monster
  - Config: ${XDG_CONFIG_HOME:-~/.config}/cookie-monster
  - Cache: ${XDG_CACHE_HOME:-~/.cache}/cookie-monster
- Example: Install the latest release and create a shim in `~/.local/bin`:

```sh
./install.sh --auto-install
```

Notes:
- The scripts use `curl` and `unzip`. Most macOS and Linux distributions include these. If not available, install them via your package manager (e.g., `apt`, `yum`, `brew`).

## Windows (native batch)

- Installer: `platforms/windows/install.bat` — extracts release ZIP into `%LOCALAPPDATA%\cookie-monster` using `curl` and `tar`.
- Shim: `platforms/windows/cookie.bat` attempts to run the installed script using `bash` (Git Bash/WSL) if present; otherwise it suggests using the PowerShell installer.

Run:

```bat
platforms\windows\install.bat
```

Notes:
- Modern Windows includes `curl` and `tar`. If absent, use PowerShell-based `install.ps1` instead.

## PowerShell

- PowerShell users can continue to use `install.ps1` to add the `CookieMonster.profile.ps1` fragment to their PowerShell profile. This remains supported on Windows, macOS, and Linux (PowerShell Core).

## No external runtime dependencies

- The native installers avoid requiring runtimes beyond the OS-provided tools (curl, tar/unzip, bash). If you need a single-binary distribution, consider building a Go/Rust binary — I can add that packaging step if desired.

## Troubleshooting

- If `~/.local/bin` (or `%USERPROFILE%\bin`) is not on your PATH, add it to your shell profile so the `cookie` command is available.

## Packaging

- Release ZIPs include both PowerShell and native artifacts so users on any platform can pick their preferred install path.
