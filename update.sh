#!/usr/bin/env bash
set -e

# Update Brewfile with all currently installed packages
if command -v brew >/dev/null 2>&1; then
  echo "Updating .Brewfile from current Homebrew packages..."
  brew bundle dump --force --global --describe
else
  echo "Homebrew is not installed or not in PATH" >&2
fi

# Update aqua registry file with installed packages
if command -v aqua >/dev/null 2>&1; then
  echo "Updating aqua.yaml from current aqua packages..."
  aqua g -a
else
  echo "aqua is not installed or not in PATH" >&2
fi

echo "Dotfile package configuration updated."
