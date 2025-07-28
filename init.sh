#!/usr/bin/env bash
set -e

# 最小限のdotfiles初期化スクリプト
# このスクリプトはHomebrewとchezmoiのインストール、dotfilesの適用のみを行います
# その他の設定はchezmoiのrun_onceスクリプトで実行されます

SCRIPT_DIR=$(cd $(dirname $0); pwd)

echo "=== Minimal Dotfiles Setup Script ==="
echo "This script will:"
echo "1. Install Homebrew (if not installed)"
echo "2. Install chezmoi"
echo "3. Apply dotfiles with chezmoi"
echo ""

# SSHキーの存在確認
if [ ! -f "$HOME/.ssh/id_ed25519" ] && [ ! -f "$HOME/.ssh/id_rsa" ]; then
    echo "⚠️  Warning: No SSH key found in ~/.ssh/"
    echo "You may have issues with private repositories."
    echo ""
fi

# GitHubのSSHホスト鍵を追加（初回接続時のプロンプトを回避）
if [ ! -f "$HOME/.ssh/known_hosts" ] || ! grep -q "github.com" "$HOME/.ssh/known_hosts"; then
    echo "Adding GitHub SSH host key..."
    mkdir -p "$HOME/.ssh"
    ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
    echo "✓ GitHub host key added"
fi

# sudo認証を最初に要求（必要な場合）
NEEDS_SUDO=false

# Homebrewがインストールされていない場合
if ! command -v brew &> /dev/null; then
    NEEDS_SUDO=true
fi

# システムのzshenvパスを事前にチェック（man zshを使う前の簡易チェック）
SYSTEM_ZSHENV_CHECK=""
if [ "$(uname)" == "Darwin" ]; then
    SYSTEM_ZSHENV_CHECK="/etc/zshenv"
elif [ "$(uname)" == "Linux" ]; then
    if [ -d "/etc/zsh" ]; then
        SYSTEM_ZSHENV_CHECK="/etc/zsh/zshenv"
    else
        SYSTEM_ZSHENV_CHECK="/etc/zshenv"
    fi
fi

# システムのzshenvに書き込む必要があり、権限がない場合
if [ -n "$SYSTEM_ZSHENV_CHECK" ]; then
    if [ ! -f "$SYSTEM_ZSHENV_CHECK" ] || ! grep -q "ZDOTDIR=" "$SYSTEM_ZSHENV_CHECK" 2>/dev/null; then
        if [ ! -w "$SYSTEM_ZSHENV_CHECK" ] && [ ! -w "$(dirname "$SYSTEM_ZSHENV_CHECK")" ]; then
            NEEDS_SUDO=true
        fi
    fi
fi

if [ "$NEEDS_SUDO" = true ]; then
    echo "This script requires administrator privileges for initial setup."
    echo "Please enter your password when prompted."
    sudo -v
    
    # sudoのタイムスタンプを定期的に更新（バックグラウンドで）
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    SUDO_PID=$!
    
    # 少し待機してsudoが確実に有効になるまで待つ
    sleep 1
fi

# /etc/zshenvにZDOTDIRを設定（早い段階で実行）
# システムのzshenv設定ファイルのパスを確認
SYSTEM_ZSHENV=""

# man zshからシステムのzshenvパスを取得（macOS/Linux共通）
if command -v zsh &> /dev/null && command -v man &> /dev/null; then
    # man zshの出力から/etc/zshenvまたは/etc/zsh/zshenvのパスを探す
    ZSHENV_PATH=$(man zsh 2>/dev/null | grep -E '^\s*/etc/(zsh/)?zshenv' | head -1 | awk '{print $1}' || true)
    if [ -n "$ZSHENV_PATH" ]; then
        SYSTEM_ZSHENV="$ZSHENV_PATH"
    fi
fi

# man zshで見つからない場合はOS別のデフォルトパスを使用
if [ -z "$SYSTEM_ZSHENV" ]; then
    if [ "$(uname)" == "Darwin" ]; then
        SYSTEM_ZSHENV="/etc/zshenv"
    elif [ "$(uname)" == "Linux" ]; then
        if [ -d "/etc/zsh" ]; then
            SYSTEM_ZSHENV="/etc/zsh/zshenv"
        else
            SYSTEM_ZSHENV="/etc/zshenv"
        fi
    fi
fi

# システムのzshenvファイルにZDOTDIRを設定
if [ -n "$SYSTEM_ZSHENV" ]; then
    if [ -f "$SYSTEM_ZSHENV" ] || [ -w "$(dirname "$SYSTEM_ZSHENV")" ]; then
        if ! grep -q "ZDOTDIR=" "$SYSTEM_ZSHENV" 2>/dev/null; then
            # sudoが必要かチェック
            if [ ! -w "$SYSTEM_ZSHENV" ] && [ ! -w "$(dirname "$SYSTEM_ZSHENV")" ]; then
                echo ""
                echo "=== Setting up ZDOTDIR in $SYSTEM_ZSHENV ==="
                echo "This requires administrator privileges."
                echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee -a "$SYSTEM_ZSHENV" > /dev/null
                echo "✓ ZDOTDIR configured in $SYSTEM_ZSHENV"
            else
                echo ""
                echo "=== Setting up ZDOTDIR in $SYSTEM_ZSHENV ==="
                echo 'export ZDOTDIR="$HOME/.config/zsh"' >> "$SYSTEM_ZSHENV"
                echo "✓ ZDOTDIR configured in $SYSTEM_ZSHENV"
            fi
        else
            echo "✓ ZDOTDIR already configured in $SYSTEM_ZSHENV"
        fi
    else
        # システムファイルに書き込めない場合は~/.zshenvを使用
        if [ ! -f "$HOME/.zshenv" ] || ! grep -q "ZDOTDIR=" "$HOME/.zshenv"; then
            echo ""
            echo "=== Setting up ZDOTDIR in ~/.zshenv ==="
            echo "Note: Could not write to $SYSTEM_ZSHENV, using ~/.zshenv instead"
            echo 'export ZDOTDIR="$HOME/.config/zsh"' >> "$HOME/.zshenv"
            echo "✓ ZDOTDIR configured in ~/.zshenv"
        else
            echo "✓ ZDOTDIR already configured in ~/.zshenv"
        fi
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
        if [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
            eval "$($HOME/.linuxbrew/bin/brew shellenv)"
        fi
    fi
}

# まず既存のHomebrewを探す
setup_homebrew_path

# Homebrewのインストール
if ! command -v brew &> /dev/null; then
    echo ""
    echo "=== Installing Homebrew ==="
    
    # OS別の前提条件確認と自動インストール
    if [ "$(uname)" == "Darwin" ]; then
        echo "Checking for Xcode Command Line Tools..."
        if ! xcode-select -p &> /dev/null; then
            echo "Installing Xcode Command Line Tools..."
            echo "This may take a few minutes. Please follow the prompts."
            xcode-select --install
            echo ""
            echo "⚠️  After installation completes, please run this script again."
            exit 1
        else
            echo "✓ Xcode Command Line Tools are installed"
        fi
    elif [ "$(uname)" == "Linux" ]; then
        echo "Checking for build dependencies..."
        
        # build-essentialのインストール確認と自動インストール
        if command -v apt-get &> /dev/null; then
            # Debian/Ubuntu系
            if ! dpkg -l build-essential &> /dev/null; then
                echo "Installing build-essential..."
                sudo apt-get update && sudo apt-get install -y build-essential curl git
                echo "✓ Build dependencies installed"
            else
                echo "✓ build-essential is already installed"
            fi
        elif command -v yum &> /dev/null; then
            # RHEL/CentOS系
            if ! rpm -q gcc gcc-c++ make &> /dev/null; then
                echo "Installing development tools..."
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y curl git
                echo "✓ Build dependencies installed"
            else
                echo "✓ Development tools are already installed"
            fi
        else
            echo "⚠️  Could not detect package manager. Please install build tools manually:"
            echo "   For Debian/Ubuntu: sudo apt-get install build-essential curl git"
            echo "   For RHEL/CentOS: sudo yum groupinstall 'Development Tools'"
        fi
    fi
    
    # NONINTERACTIVE=1でプロンプトをスキップ
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # 新しくインストールしたHomebrewのパスを設定
    setup_homebrew_path
    
    # Homebrewが正しくインストールされたか確認
    if command -v brew &> /dev/null; then
        echo "✓ Homebrew installed"
    else
        echo "❌ Error: Homebrew installation failed"
        exit 1
    fi
else
    echo "✓ Homebrew is already installed"
fi

# chezmoiのインストール
echo ""
echo "=== Installing chezmoi ==="
if ! command -v chezmoi &> /dev/null; then
    brew install chezmoi
    echo "✓ chezmoi installed"
else
    echo "✓ chezmoi is already installed"
fi

# chezmoiでdotfilesを適用
echo ""
echo "=== Applying dotfiles with chezmoi ==="

# chezmoi用の設定ファイルを一時的に作成
CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"
mkdir -p "$CHEZMOI_CONFIG_DIR"

# 基本的な設定のみ（詳細な設定はchezmoiの対話的プロンプトで入力）
cat > "$CHEZMOI_CONFIG_DIR/chezmoi.yaml" <<EOF
# This is a minimal config file
# Additional configuration will be prompted during chezmoi init
data:
  name: "okash1n"
  email: "48118431+okash1n@users.noreply.github.com"
EOF

# 初期化フラグを作成（run_onchangeスクリプトの初回実行をスキップするため）
touch "$CHEZMOI_CONFIG_DIR/.chezmoi_initializing"

# chezmoiの初期化と適用
echo "Initializing and applying dotfiles..."
chezmoi init --source "$SCRIPT_DIR" --apply

echo ""
echo "=== Setup Complete! ==="
echo ""
echo "🎉 Basic dotfiles setup is complete!"
echo ""
echo "Additional setup tasks will be executed by chezmoi's run_once scripts."
echo "You may need to restart your shell or re-login for all changes to take effect."
echo ""
echo "To manage your dotfiles going forward:"
echo "  chezmoi diff       # See what changes chezmoi will make"
echo "  chezmoi apply      # Apply the changes"
echo "  chezmoi update     # Pull latest changes and apply"
echo "  chezmoi cd         # Go to chezmoi source directory"
echo "  chezmoi add <file> # Add a new file to chezmoi"
echo ""

# 追加手順の案内（実行環境に基づく）
echo "=== Final setup steps ==="
echo ""

# Brewのパスを検出（グローバルに使用）
BREW_PATH=""
BREW_PREFIX=""
if [ -f "/opt/homebrew/bin/brew" ]; then
    BREW_PATH="/opt/homebrew/bin/brew"
    BREW_PREFIX="/opt/homebrew"
elif [ -f "/usr/local/bin/brew" ]; then
    BREW_PATH="/usr/local/bin/brew"
    BREW_PREFIX="/usr/local"
elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
    BREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
    BREW_PREFIX="/home/linuxbrew/.linuxbrew"
elif [ -f "$HOME/.linuxbrew/bin/brew" ]; then
    BREW_PATH="$HOME/.linuxbrew/bin/brew"
    BREW_PREFIX="$HOME/.linuxbrew"
fi

# zshがインストールされたが、現在のシェルがzshでない場合
ZSH_PATH="$(PATH="$BREW_PREFIX/bin:$PATH" which zsh 2>/dev/null || true)"
if [ -n "$ZSH_PATH" ] && [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Setting zsh as your default shell..."
    
    # /etc/shellsにzshを追加
    if ! grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
        echo "Adding $ZSH_PATH to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
        echo "✓ zsh added to /etc/shells"
    fi
    
    # デフォルトシェルをzshに変更
    echo "Changing default shell to zsh..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    echo "✓ Default shell changed to zsh"
    echo ""
    echo "Note: You'll need to start a new terminal session for the shell change to take effect."
    echo ""
fi

# 初期化フラグを削除（通常運用でrun_onchangeが動作するように）
rm -f "$CHEZMOI_CONFIG_DIR/.chezmoi_initializing" 2>/dev/null || true

# sudoのバックグラウンドプロセスをクリーンアップ
if [ ! -z "$SUDO_PID" ]; then
    kill $SUDO_PID 2>/dev/null || true
fi

# 親プロセスがmakeの場合は、execを使わない
if [ "$1" != "--no-exec" ]; then
    # 直接実行された場合のみzshを起動
    if [ -z "$MAKE" ] && [ -z "$MAKELEVEL" ]; then
        # zshのパスを再確認（Homebrewのパスを含む）
        ZSH_FINAL_PATH="$(PATH="$BREW_PREFIX/bin:$PATH" which zsh 2>/dev/null || which zsh 2>/dev/null || true)"
        
        if [ -n "$ZSH_FINAL_PATH" ]; then
            # デフォルトシェルがzshに変更されている場合は、exec zshで再起動
            # そうでない場合は、明示的にzshを起動
            exec "$ZSH_FINAL_PATH" -l
        else
            echo ""
            echo "⚠️  zsh is not installed. The installation may have failed."
        fi
    fi
fi

# makeから実行された場合は正常終了を明示
exit 0