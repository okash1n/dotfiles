#!/usr/bin/env bash
set -e

# このスクリプトは新しいマシンでdotfilesをセットアップするための初期化スクリプトです
# 前提条件：
# 1. GitHubにSSHキーが登録済み
# 2. このリポジトリが ~/dotfiles にクローン済み

SCRIPT_DIR=$(cd $(dirname $0); pwd)

echo "=== Dotfiles Setup Script ==="
echo "This script will:"
echo "1. Install Rosetta (if on Apple Silicon)"
echo "2. Install Homebrew"
echo "3. Install packages from Brewfile (including chezmoi)"
echo "4. Apply dotfiles with chezmoi"
echo ""

# SSHキーの存在確認
if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "⚠️  Warning: No SSH key found in ~/.ssh/"
    echo "You may have issues with private repositories."
    echo ""
fi

# Rosettaのインストール (Apple Siliconの場合)
if [[ "$(uname)" == "Darwin" && "$(uname -m)" == "arm64" ]]; then
    echo "=== Installing Rosetta ==="
    if ! /usr/bin/pgrep oahd &>/dev/null; then
        echo "Installing Rosetta..."
        /usr/sbin/softwareupdate --install-rosetta --agree-to-license
        echo "✓ Rosetta installed"
    else
        echo "✓ Rosetta is already installed"
    fi
fi

# Homebrewのパスを設定（既にインストールされている場合のため）
setup_homebrew_path() {
    if [ "$(uname)" == "Darwin" ]; then
        # Apple Silicon Mac
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        # Intel Mac
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    elif [ "$(uname)" == "Linux" ]; then
        # Linux
        test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
        test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    fi
}

# まず既存のHomebrewを探す
setup_homebrew_path

# Homebrewのインストール
if ! command -v brew &> /dev/null; then
    echo ""
    echo "=== Installing Homebrew ==="
    if [ -t 0 ]; then
        # 対話的な環境
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        # 非対話的な環境
        echo "❌ Error: Homebrew installation requires an interactive terminal"
        echo "Please install Homebrew manually first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        exit 1
    fi
    
    # 新しくインストールしたHomebrewのパスを設定
    setup_homebrew_path
    echo "✓ Homebrew installed"
else
    echo "✓ Homebrew is already installed"
fi

# Brewfileからパッケージをインストール
echo ""
echo "=== Installing packages from Brewfile ==="
# リポジトリ内のBrewfileを使用
if [ -f "$SCRIPT_DIR/dot_Brewfile" ]; then
    brew bundle --file="$SCRIPT_DIR/dot_Brewfile"
    echo "✓ All packages installed"
else
    echo "❌ Error: Brewfile not found at $SCRIPT_DIR/dot_Brewfile"
    exit 1
fi

# chezmoiが正しくインストールされたか確認
if ! command -v chezmoi &> /dev/null; then
    echo "❌ Error: chezmoi was not installed properly"
    exit 1
fi

# chezmoiでdotfilesを適用
echo ""
echo "=== Applying dotfiles with chezmoi ==="
chezmoi init --source "$SCRIPT_DIR" --apply
echo "✓ Dotfiles applied"

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "🎉 Your dotfiles have been successfully set up!"
echo ""
echo "To manage your dotfiles going forward:"
echo "  chezmoi diff       # See what changes chezmoi will make"
echo "  chezmoi apply      # Apply the changes"
echo "  chezmoi update     # Pull latest changes and apply"
echo "  chezmoi cd         # Go to chezmoi source directory"
echo "  chezmoi add <file> # Add a new file to chezmoi"
echo ""

# zshがデフォルトシェルでない場合は案内
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "To set zsh as your default shell:"
    echo '  echo "$(which zsh)" | sudo tee -a /etc/shells'
    echo '  chsh -s "$(which zsh)"'
    echo ""
fi

echo "Please restart your terminal to ensure all changes take effect."