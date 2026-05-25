#!/usr/bin/env bash
# Quick dependency checker for cookie-monster native installers
set -euo pipefail

missing=0

check() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Missing: $1"
    missing=$((missing+1))
  else
    echo "Found: $1"
  fi
}

echo "Checking common tools..."
check curl
check unzip || true
check tar || true
check python3 || true
check python || true

if [ "$missing" -gt 0 ]; then
  echo
  echo "Some recommended tools are missing. The installers will try fallbacks when possible (tar/python/PowerShell)."
  echo "On Debian/Ubuntu: sudo apt install curl unzip tar python3"
  echo "On macOS: brew install curl unzip"
  exit 1
fi

echo "All required tools are present or fallbacks are available."
exit 0
