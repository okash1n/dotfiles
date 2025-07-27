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

# sudo認証を最初に要求（必要な場合）
NEEDS_SUDO=false
if [ ! -f "/etc/zshenv" ] || ! grep -q "ZDOTDIR=" "/etc/zshenv"; then
    NEEDS_SUDO=true
fi
if ! command -v brew &> /dev/null; then
    NEEDS_SUDO=true
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

# /etc/zshenvにZDOTDIRを設定（まだ設定されていない場合）
if [ ! -f "/etc/zshenv" ] || ! grep -q "ZDOTDIR=" "/etc/zshenv"; then
    echo ""
    echo "=== Setting up ZDOTDIR in /etc/zshenv ==="
    # sudo -n で非対話的に実行（既に認証済みの場合）
    if sudo -n true 2>/dev/null; then
        echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee -a /etc/zshenv > /dev/null
    else
        # 認証が必要な場合
        echo 'export ZDOTDIR="$HOME/.config/zsh"' | sudo tee -a /etc/zshenv > /dev/null
    fi
    echo "✓ ZDOTDIR configured in /etc/zshenv"
fi

# chezmoiでdotfilesを適用
echo ""
echo "=== Applying dotfiles with chezmoi ==="
# ユーザー情報を取得（gitの設定から取得を試みる）
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

# chezmoi用の設定ファイルを一時的に作成
CHEZMOI_CONFIG_DIR="$HOME/.config/chezmoi"
mkdir -p "$CHEZMOI_CONFIG_DIR"

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    echo "Git user information not found. Setting up chezmoi with defaults..."
    cat > "$CHEZMOI_CONFIG_DIR/chezmoi.yaml" <<EOF
data:
  name: "User"
  email: "user@example.com"
EOF
else
    echo "Using Git configuration: $GIT_NAME <$GIT_EMAIL>"
    cat > "$CHEZMOI_CONFIG_DIR/chezmoi.yaml" <<EOF
data:
  name: "$GIT_NAME"
  email: "$GIT_EMAIL"
EOF
fi

chezmoi init --source "$SCRIPT_DIR" --apply
echo "✓ Dotfiles applied"

# chezmoi初期化完了フラグを作成
mkdir -p "$HOME/.config/chezmoi"
touch "$HOME/.config/chezmoi/.chezmoi_initialized"

# プライベートアセットのインストール（VSCode拡張機能など）
echo ""
echo "=== Installing private assets ==="
if [ -d "$HOME/ghq/github.com/okash1n/dracula-pro" ]; then
    echo "Found dracula-pro repository"
    if [ -f "$HOME/ghq/github.com/okash1n/dracula-pro/themes/visual-studio-code/dracula-pro.vsix" ]; then
        echo "Installing Dracula Pro theme..."
        code --install-extension "$HOME/ghq/github.com/okash1n/dracula-pro/themes/visual-studio-code/dracula-pro.vsix"
        echo "✓ Dracula Pro theme installed"
    fi
else
    # ghqでクローン（SSHを明示的に使用）
    if command -v ghq &> /dev/null; then
        echo "Cloning dracula-pro repository..."
        ghq get git@github.com:okash1n/dracula-pro.git
        if [ -f "$HOME/ghq/github.com/okash1n/dracula-pro/themes/visual-studio-code/dracula-pro.vsix" ]; then
            echo "Installing Dracula Pro theme..."
            code --install-extension "$HOME/ghq/github.com/okash1n/dracula-pro/themes/visual-studio-code/dracula-pro.vsix"
            echo "✓ Dracula Pro theme installed"
        fi
    else
        echo "⚠️  ghq or gh not available. Skipping private assets installation."
        echo "   To install manually: ghq get okash1n/dracula-pro"
    fi
fi

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

# zshのパスを/etc/shellsに追加するためのコマンドと、デフォルトシェルに設定するコマンドの案内
echo "To add zsh to /etc/shells and set it as your default shell, run the following commands:"
echo 'echo "$(which zsh)" | sudo tee -a /etc/shells'
echo 'chsh -s "$(which zsh)"'

# sudoのバックグラウンドプロセスをクリーンアップ
if [ ! -z "$SUDO_PID" ]; then
    kill $SUDO_PID 2>/dev/null
fi

# zshを再実行することで、.zprofileなどを読み込ませる
exec zsh -l