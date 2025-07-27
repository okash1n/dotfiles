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
    
    # macOSの場合、Xcodeコマンドラインツールの確認を促す
    if [ "$(uname)" == "Darwin" ]; then
        echo "Note: Homebrew requires Xcode Command Line Tools."
        echo "If prompted, please install them and run this script again."
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