#!/usr/bin/env bash
set -e

# このスクリプトは新しいマシンでdotfilesをセットアップするための簡易スクリプトです
# chezmoiがインストールされていない場合は、まずchezmoiをインストールします

echo "Setting up dotfiles with chezmoi..."

# chezmoiがインストールされているかチェック
if ! command -v chezmoi &> /dev/null; then
    echo "chezmoi is not installed. Installing chezmoi..."
    
    # OSに応じたインストール方法を選択
    if [ "$(uname)" == "Darwin" ]; then
        # macOSの場合
        if command -v brew &> /dev/null; then
            brew install chezmoi
        else
            # Homebrewがない場合は直接インストール
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
            export PATH="$HOME/.local/bin:$PATH"
        fi
    elif [ "$(uname)" == "Linux" ]; then
        # Linuxの場合
        if command -v brew &> /dev/null; then
            brew install chezmoi
        else
            # Homebrewがない場合は直接インストール
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b $HOME/.local/bin
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi
fi

# GitHubリポジトリからdotfilesを初期化する場合
if [ -n "$1" ]; then
    echo "Initializing dotfiles from repository: $1"
    chezmoi init --apply "$1"
else
    # ローカルのdotfilesディレクトリから初期化
    SCRIPT_DIR=$(cd $(dirname $0); pwd)
    echo "Initializing dotfiles from local directory: $SCRIPT_DIR"
    chezmoi init --source "$SCRIPT_DIR" --apply
fi

echo "Setup complete!"
echo ""
echo "To manage your dotfiles, use the following commands:"
echo "  chezmoi diff       # See what changes chezmoi will make"
echo "  chezmoi apply      # Apply the changes"
echo "  chezmoi update     # Pull latest changes and apply"
echo "  chezmoi cd         # Go to chezmoi source directory"
echo ""
echo "To add new files to chezmoi:"
echo "  chezmoi add ~/.config/some-file"
echo ""

# zshがデフォルトシェルでない場合は案内を表示
if [ "$SHELL" != "$(which zsh)" ]; then
    echo "To set zsh as your default shell, run:"
    echo '  echo "$(which zsh)" | sudo tee -a /etc/shells'
    echo '  chsh -s "$(which zsh)"'
fi