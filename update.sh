#!/usr/bin/env bash
set -e

# Update Brewfile with all currently installed packages
if command -v brew >/dev/null 2>&1; then
  echo "Updating .Brewfile from current Homebrew packages..."
  brew bundle dump --force --global --describe
  echo "Homebrew configuration updated successfully."
else
  echo "Homebrew is not installed or not in PATH" >&2
  exit 1
fi