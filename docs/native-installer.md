# Native installer (`install.sh`) Reference

Location: `install.sh` (repo root) and `platforms/*/install.sh`.

Purpose: install files into XDG-friendly directories and create a shim at `~/.local/bin/cookie`.

Flags

- `--update-now`
  - Download the latest release ZIP into the cache (no install). Writes the zip into `${XDG_CACHE_HOME:-~/.cache}/cookie-monster/downloads`.
- `--auto-install`
  - Download the latest release and install it into `${XDG_DATA_HOME:-~/.local/share}/cookie-monster`, creating a shim in `${HOME}/.local/bin`.
- `--install-local`
  - Install from the current repo copy (useful for development). Copies repository files into the install location and creates a shim.
- `--help`
  - Show usage text.

Extraction fallbacks (in order of preference)

1. `unzip` (preferred)
2. `tar -xf` (if available and supports zip)
3. `python3` using the `zipfile` module
4. `python` (2.x/3.x) using the `zipfile` module

If none exist, the installer errors with a helpful message and exit code.

Notes

- The installer uses `curl` to download the release; if `curl` is missing users should install it or use the `check-deps.sh` helper.
- After installation, the shim prints a warning if `${HOME}/.local/bin` is not in the user's PATH.

Examples

```sh
# Download only (cache)
./install.sh --update-now

# Download and install
./install.sh --auto-install

# Install from repo copy
./install.sh --install-local
```
