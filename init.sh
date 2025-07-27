#!/usr/bin/env bash
set -e

# 最小限のdotfiles初期化スクリプト (v0.9.1)
# このスクリプトはHomebrewとchezmoiのインストール、dotfilesの適用のみを行います
# その他の設定はchezmoiのrun_onceスクリプトで実行されます

SCRIPT_DIR=$(cd $(dirname $0); pwd)

echo "=== Minimal Dotfiles Setup Script (v0.9.1) ==="
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

# macOSでHomebrewのインストールまたは/etc/zshenvの設定が必要な場合
if [ "$(uname)" == "Darwin" ]; then
    if [ ! -f "/etc/zshenv" ] || ! grep -q "ZDOTDIR=" "/etc/zshenv" ]; then
        NEEDS_SUDO=true
    fi
    if ! command -v brew &> /dev/null; then
        NEEDS_SUDO=true
    fi
elif [ "$(uname)" == "Linux" ]; then
    # Linuxでシステムのzshenvに書き込む必要がある場合
    SYSTEM_ZSHENV_CHECK=""
    if [ -d "/etc/zsh" ]; then
        SYSTEM_ZSHENV_CHECK="/etc/zsh/zshenv"
    else
        SYSTEM_ZSHENV_CHECK="/etc/zshenv"
    fi
    
    # システムのzshenvが存在し、ZDOTDIR設定がなく、書き込み権限がない場合
    if [ -f "$SYSTEM_ZSHENV_CHECK" ] && ! grep -q "ZDOTDIR=" "$SYSTEM_ZSHENV_CHECK" 2>/dev/null && [ ! -w "$SYSTEM_ZSHENV_CHECK" ]; then
        NEEDS_SUDO=true
    fi
    
    # Homebrewがインストールされていない場合（Linuxでも必要な場合がある）
    if ! command -v brew &> /dev/null; then
        # Linuxの場合、Homebrewのインストールにsudoは不要だが、依存関係のインストールで必要になる可能性がある
        NEEDS_SUDO=true
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

# /etc/zshenvにZDOTDIRを設定（macOSの場合のみ、早い段階で実行）
if [ "$(uname)" == "Darwin" ]; then
    if [ "$NEEDS_SUDO" = true ] && ([ ! -f "/etc/zshenv" ] || ! grep -q "ZDOTDIR=" "/etc/zshenv"); then
        echo ""
        echo "=== Setting up ZDOTDIR in /etc/zshenv ==="
        echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee -a /etc/zshenv > /dev/null
        echo "✓ ZDOTDIR configured in /etc/zshenv"
    fi
elif [ "$(uname)" == "Linux" ]; then
    # Linuxの場合、システムのzshenv設定ファイルのパスを確認
    SYSTEM_ZSHENV=""
    
    # man zshからシステムのzshenvパスを取得
    if command -v zsh &> /dev/null && command -v man &> /dev/null; then
        # man zshの出力から/etc/zshenvまたは/etc/zsh/zshenvのパスを探す
        ZSHENV_PATH=$(man zsh 2>/dev/null | grep -E '^\s*/etc/(zsh/)?zshenv' | head -1 | awk '{print $1}' || true)
        if [ -n "$ZSHENV_PATH" ]; then
            SYSTEM_ZSHENV="$ZSHENV_PATH"
        fi
    fi
    
    # man zshで見つからない場合は一般的なパスをチェック
    if [ -z "$SYSTEM_ZSHENV" ]; then
        if [ -d "/etc/zsh" ]; then
            SYSTEM_ZSHENV="/etc/zsh/zshenv"
        else
            SYSTEM_ZSHENV="/etc/zshenv"
        fi
    fi
    
    # システムのzshenvファイルが存在し、書き込み可能な場合はそこに設定
    if [ -f "$SYSTEM_ZSHENV" ] || [ -w "$(dirname "$SYSTEM_ZSHENV")" ]; then
        if ! grep -q "ZDOTDIR=" "$SYSTEM_ZSHENV" 2>/dev/null; then
            if [ -w "$SYSTEM_ZSHENV" ] || [ -w "$(dirname "$SYSTEM_ZSHENV")" ]; then
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
                # システムファイルに書き込めない場合は~/.zshenvを使用
                echo ""
                echo "=== Setting up ZDOTDIR in ~/.zshenv ==="
                echo "Note: Could not write to $SYSTEM_ZSHENV, using ~/.zshenv instead"
                echo 'export ZDOTDIR="$HOME/.config/zsh"' >> "$HOME/.zshenv"
                echo "✓ ZDOTDIR configured in ~/.zshenv"
            fi
        else
            echo "✓ ZDOTDIR already configured in $SYSTEM_ZSHENV"
        fi
    else
        # システムのzshenvが存在しない場合は~/.zshenvを使用
        if [ ! -f "$HOME/.zshenv" ] || ! grep -q "ZDOTDIR=" "$HOME/.zshenv"; then
            echo ""
            echo "=== Setting up ZDOTDIR in ~/.zshenv ==="
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
    
    # OS別の注意事項を表示
    if [ "$(uname)" == "Darwin" ]; then
        echo "Note: Homebrew requires Xcode Command Line Tools."
        echo "If prompted, please install them and run this script again."
    elif [ "$(uname)" == "Linux" ]; then
        echo "Note: Homebrew on Linux may require additional dependencies."
        echo "The installer will attempt to install them automatically."
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

# zshのパスを/etc/shellsに追加するためのコマンドと、デフォルトシェルに設定するコマンドの案内
echo "To add zsh to /etc/shells and set it as your default shell, run the following commands:"
echo 'echo "$(which zsh)" | sudo tee -a /etc/shells'
echo 'chsh -s "$(which zsh)"'

# sudoのバックグラウンドプロセスをクリーンアップ
if [ ! -z "$SUDO_PID" ]; then
    kill $SUDO_PID 2>/dev/null || true
fi

# 親プロセスがmakeの場合は、execを使わない
if [ "$1" != "--no-exec" ]; then
    # 直接実行された場合のみzshを起動
    if [ -z "$MAKE" ] && [ -z "$MAKELEVEL" ]; then
        # zshを再実行することで、.zprofileなどを読み込ませる
        if command -v zsh &> /dev/null; then
            exec zsh -l
        else
            echo ""
            echo "⚠️  zsh is not installed. Please install it manually and re-run the shell."
        fi
    fi
fi

# makeから実行された場合は正常終了を明示
exit 0