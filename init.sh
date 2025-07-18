#!/usr/bin/env bash

# スクリプト自身のディレクトリを確実に格納
SCRIPT_DIR=$(cd $(dirname $0); pwd)

# Rosettaのインストール (Apple Siliconの場合)
install_rosetta() {
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
}

# Homebrew のインストール
install_homebrew() {
  echo "Installing Homebrew..."
  if [ "$(uname)" == "Darwin" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    HOMEBREW_PATH="/opt/homebrew/bin/brew"
  elif [ "$(uname)" == "Linux" ]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    test -d ~/.linuxbrew && eval $(~/.linuxbrew/bin/brew shellenv)
    test -d /home/linuxbrew/.linuxbrew && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    HOMEBREW_PATH="/home/linuxbrew/.linuxbrew/bin/brew"
  fi

  # パス設定を追加
  eval "$($HOMEBREW_PATH shellenv)"
}

# 設定ファイルとディレクトリのシンボリックリンク作成
link_dotfiles() {
  echo "Creating symbolic links for config files and directories in ~/dotfiles/configs/..."

  CONFIG_DIR="$SCRIPT_DIR/configs"
  for item in "$CONFIG_DIR"/* "$CONFIG_DIR"/.*; do
    [ "$(basename "$item")" == "." ] || [ "$(basename "$item")" == ".." ] && continue
    ln -snf "$item" "$HOME/$(basename "$item")"
  done
}

# Homebrew と Aqua でパッケージのインストール
install_packages() {
  echo "Installing packages with Homebrew and Aqua..."
  "$HOMEBREW_PATH" bundle --global  # --globalでホームディレクトリの.Brewfileを参照
  
  # Aquaのインストール
  AQUA_PATH="$("$HOMEBREW_PATH" --prefix)/bin/aqua"
  "$AQUA_PATH" i -a
}

# update.shの定期実行を設定 (cronジョブ)
setup_cron_job() {
  echo "Setting up cron job for update.sh..."
  
  # update.shのフルパス
  UPDATE_SCRIPT="$SCRIPT_DIR/update.sh"
  
  # cronジョブの内容 (3時間ごとに実行)
  # HOME環境変数を明示的に設定
  CRON_JOB="0 */3 * * * HOME=$HOME /bin/bash $UPDATE_SCRIPT >> /tmp/dotfiles-update.log 2>&1"
  
  # 既存のcrontabを取得
  CURRENT_CRONTAB=$(crontab -l 2>/dev/null || echo "")
  
  # 既にupdate.shのcronジョブが存在するかチェック
  if echo "$CURRENT_CRONTAB" | grep -q "$UPDATE_SCRIPT"; then
    echo "Cron job for update.sh already exists. Skipping..."
  else
    # 新しいcronジョブを追加
    (echo "$CURRENT_CRONTAB"; echo "$CRON_JOB") | crontab -
    echo "Cron job added: Execution of update.sh every 3 hours"
    echo "Log file: /tmp/dotfiles-update.log"
  fi
}

# 実行
install_rosetta
install_homebrew
link_dotfiles
install_packages
setup_cron_job

# 実行完了メッセージ
echo "Setup complete!"

# zshのパスを/etc/shellsに追加するためのコマンドと、デフォルトシェルに設定するコマンドの案内
echo "To add zsh to /etc/shells and set it as your default shell, run the following commands:"
echo 'echo "$(which zsh)" | sudo tee -a /etc/shells'
echo 'chsh -s "$(which zsh)"'

# zshを再実行することで、.zprofileなどを読み込ませる
exec zsh -l
