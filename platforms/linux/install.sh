#!/usr/bin/env bash
# Linux installer (copy of root install.sh)

$(sed -n '1,240p' "c:\Users\Class\3D Objects\Code\cookie-monster\install.sh" 2>/dev/null || cat <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

REPO=${REPO:-"ilim-cell/cookie-monster"}
HOME_DIR="${HOME:-$PWD}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME_DIR/.local/share}"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME_DIR/.config}"
XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME_DIR/.cache}"
INSTALL_DIR="$XDG_DATA_HOME/cookie-monster"
CONFIG_DIR="$XDG_CONFIG_HOME/cookie-monster"
CACHE_DIR="$XDG_CACHE_HOME/cookie-monster"
DOWNLOADS_DIR="$CACHE_DIR/downloads"
STAGE_DIR="$CACHE_DIR/stage"
BIN_DIR="${BIN_DIR:-$HOME_DIR/.local/bin}"

ensure_dir() { mkdir -p "$1"; }

is_tty() { [ -t 0 ] && [ -t 1 ]; }

spinner() {
  local msg="$1"
  local duration_seconds="${2:-1}"
  if ! is_tty; then echo "$msg"; return; fi
  local frames=("[. ]" "[o ]" "[oo]" "[ o]" "[  ]")
  local frame_count=${#frames[@]}
  local delay=$(awk -v d="$duration_seconds" -v c="$frame_count" 'BEGIN{printf "%.2f", d/c}')
  for i in "${!frames[@]}"; do
    printf "\r%s %s" "${frames[$i]}" "$msg"
    sleep "$delay"
  done
  printf "\r%s\n" "$msg"
}

download_latest() {
  ensure_dir "$DOWNLOADS_DIR"
  local api="https://api.github.com/repos/$REPO/releases/latest"
  local json
  json=$(curl -sSfL -H "User-Agent: cookie-monster-installer" "$api")
  local url
  url=$(printf '%s' "$json" | grep -o '"browser_download_url": *"[^"]*cookie-monster.zip"' | sed -E 's/"browser_download_url": *"([^"]*)"/\1/')
  if [ -z "$url" ]; then
    echo "No cookie-monster.zip asset found in latest release." >&2
    return 1
  fi
  local filename="cookie-monster.zip"
  local dest="$DOWNLOADS_DIR/$filename"
  if [ ! -f "$dest" ]; then
    spinner "Downloading latest release..." 1
    curl -sSfL "$url" -o "$dest"
  else
    echo "Using cached release: $dest"
  fi
  echo "$dest"
}

extract_zip() {
  local zip="$1"
  ensure_dir "$STAGE_DIR"
  rm -rf "$STAGE_DIR"/* || true
  spinner "Extracting release..." 1
  unzip -q "$zip" -d "$STAGE_DIR"
  echo "$STAGE_DIR"
}

make_shim() {
  local target="$1"
  ensure_dir "$BIN_DIR"
  local shim="$BIN_DIR/cookie"
  cat >"$shim" <<EOF
#!/usr/bin/env bash
exec "$target" "$@"
EOF
  chmod +x "$shim"
  echo "$shim"
}

install_from_stage() {
  ensure_dir "$INSTALL_DIR"
  # copy files from stage into install dir
  cp -a "$STAGE_DIR/". "$INSTALL_DIR/"
  echo "Installed files to $INSTALL_DIR"
  if [ -f "$INSTALL_DIR/cookie" ]; then
    local shim
    shim=$(make_shim "$INSTALL_DIR/cookie")
    echo "Installed shim at $shim"
    if ! echo "$PATH" | tr ':' '\n' | grep -qx "$BIN_DIR"; then
      echo "Warning: $BIN_DIR not found in PATH. Add it to your shell profile to run 'cookie' globally." >&2
    fi
  fi
}

case "${1:-}" in
  --update-now)
    zip=$(download_latest)
    extract_zip "$zip"
    ;;
  --auto-install)
    zip=$(download_latest)
    extract_zip "$zip"
    install_from_stage
    ;;
  --install-local)
    ensure_dir "$INSTALL_DIR"
    cp -a . "$INSTALL_DIR/"
    if [ -f "$INSTALL_DIR/cookie" ]; then
      make_shim "$INSTALL_DIR/cookie"
    fi
    ;;
  --help|-h|help)
    cat <<'EOF'
Usage: install.sh [--update-now|--auto-install|--install-local]

Options:
  --update-now     Download latest release into cache (no install)
  --auto-install   Download and install latest release to XDG data dir
  --install-local   Install from current repo copy into XDG data dir
  --help            Show this message
EOF
    ;;
  *)
    echo "No action specified. Running interactive installer menu."
    if is_tty; then
      echo "1) Install from this repo copy"
      echo "2) Update now only (download to cache)"
      echo "3) Automatically install latest release"
      echo "4) Exit"
      printf 'Enter choice (1-4): '
      read -r choice
      case "$choice" in
        2) shift; set -- --update-now; exec "$0" "$@" ;;
        3) shift; set -- --auto-install; exec "$0" "$@" ;;
        4) echo "Installer canceled."; exit 0 ;;
        *) shift; set -- --install-local; exec "$0" "$@" ;;
      esac
    fi
    ;;
esac
EOF)