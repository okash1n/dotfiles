#!/usr/bin/env bash
set -e

# Rosettaのインストール (Apple Siliconの場合)
if [[ "$(uname)" == "Darwin" && "$(uname -m)" == "arm64" ]]; then
    echo "Checking for Rosetta..."
    if ! /usr/bin/pgrep oahd &>/dev/null; then
        echo "Rosetta not found. Installing Rosetta..."
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        echo "Rosetta installation complete."
    else
        echo "Rosetta is already installed."
    fi
fi

# Homebrewがインストールされているかチェック
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    if [ "$(uname)" == "Darwin" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    elif [ "$(uname)" == "Linux" ]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    echo "Homebrew installation complete."
else
    echo "Homebrew is already installed."
fi