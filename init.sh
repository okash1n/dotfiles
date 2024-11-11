#!/bin/bash

# ログファイルの準備
LOG_FILE="setup_log_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -i $LOG_FILE) 2>&1

# システムの種類を判別
if [[ "$(uname)" == "Darwin" ]]; then
    OS="macOS"
elif [[ "$(uname)" == "Linux" ]]; then
    OS="Linux"
else
    echo "Unsupported OS"
    exit 1
fi

echo "Starting setup for $OS..."

# Homebrewのインストール
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    if [[ "$OS" == "macOS" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ "$(uname -m)" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
            echo 'eval "$('/opt/homebrew/bin/brew' shellenv)"' >> ~/.profile
        else
            eval "$(/usr/local/bin/brew shellenv)"
            echo 'eval "$('/usr/local/bin/brew' shellenv)"' >> ~/.profile
        fi
    elif [[ "$OS" == "Linux" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$('/home/linuxbrew/.linuxbrew/bin/brew' shellenv)"
        echo 'eval "$('/home/linuxbrew/.linuxbrew/bin/brew' shellenv)"' >> ~/.profile
    fi
else
    echo "Homebrew is already installed. Skipping..."
fi

# Homebrewのアップデート
echo "Updating Homebrew..."
brew update

# Brewfileの実行（パッケージのインストール）
if [ -f ~/dotfiles/Brewfile ]; then
    echo "Installing packages from Brewfile..."
    brew bundle --file ~/dotfiles/Brewfile
else
    echo "Brewfile not found. Skipping package installation from Brewfile..."
fi

# Aquaのインストール
if ! command -v aqua &> /dev/null; then
    echo "Installing Aqua..."
    curl -sSfL https://raw.githubusercontent.com/aquaproj/aqua-installer/main/aqua-installer | bash
    echo 'export PATH="$HOME/.aqua/bin:$PATH"' >> ~/.profile
    source ~/.profile
else
    echo "Aqua is already installed. Skipping..."
fi

# Aquaのアップデート
if command -v aqua &> /dev/null; then
    echo "Updating Aqua..."
    aqua update -a
fi

# Aquaパッケージのインストール
if [ -f ~/dotfiles/aqua.yaml ]; then
    echo "Installing packages from aqua.yaml..."
    aqua install -c ~/dotfiles/aqua.yaml
else
    echo "aqua.yaml not found. Skipping package installation from aqua.yaml..."
fi

# セットアップ後の検証
echo "Verifying installations..."
command -v git &> /dev/null && git --version
command -v brew &> /dev/null && brew --version
command -v aqua &> /dev/null && aqua --version

# 終了メッセージ
echo "Setup complete for $OS."
