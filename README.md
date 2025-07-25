# dotfiles

okash1nのdotfiles（令和最新版）

このリポジトリは[chezmoi](https://www.chezmoi.io/)を使用してdotfilesを管理しています。

## 🚀 クイックスタート

### 前提条件

1. **GitHubにSSHキーを登録**
   ```bash
   ssh-keygen -t ed25519 -C "your-email@example.com"
   cat ~/.ssh/id_ed25519.pub
   # 出力をコピーしてGitHubに登録: https://github.com/settings/keys
   ```

2. **macOSの場合**: Xcodeコマンドラインツールをインストール
   ```bash
   xcode-select --install
   ```

### セットアップ

```bash
# 1. リポジトリをクローン
git clone git@github.com:okash1n/dotfiles.git ~/dotfiles

# 2. セットアップスクリプトを実行
cd ~/dotfiles
make init  # または ./init.sh
```

これにより以下が自動的に実行されます：
- 🍺 Homebrewのインストール
- 📦 Brewfileに定義されたパッケージのインストール（chezmoi含む）
- ⚙️ chezmoiによるdotfilesの適用
- 🔄 自動更新の設定（毎日12:00）

## 📁 ディレクトリ構造

```
dotfiles/
├── dot_config/           # ~/.config/ に配置される設定ファイル
│   ├── homebrew/        # Brewfile
│   ├── npm/             # NPMグローバルパッケージ
│   ├── zsh/             # Zsh設定
│   └── ...
├── run_onchange_*.sh.tmpl # ファイル変更時に実行されるスクリプト
├── .chezmoi.toml.tmpl    # chezmoi設定テンプレート
├── .chezmoiignore        # chezmoiが無視するファイル
└── init.sh               # 初期セットアップスクリプト
```

## 🔧 使い方

### 日常的な操作

```bash
# 変更を確認
chezmoi diff

# 変更を適用
chezmoi apply

# リポジトリの最新を取得して適用
chezmoi update

# 新しいファイルをchezmoiで管理
chezmoi add ~/.config/some-config

# chezmoi管理ディレクトリに移動
chezmoi cd
```

### パッケージ管理

**Homebrewパッケージを追加した場合**:
```bash
# Brewfileを更新
brew bundle dump --file=~/.config/homebrew/Brewfile --force

# chezmoiに反映
chezmoi add ~/.config/homebrew/Brewfile
```

**NPMグローバルパッケージ**:
- `~/.config/npm/global-packages.json`を編集してchezmoiに追加

### 自動更新

毎日12:00に自動的に`chezmoi update --apply`が実行されます。

手動で無効化する場合：
```bash
launchctl unload ~/Library/LaunchAgents/com.chezmoi.update.plist
rm ~/Library/LaunchAgents/com.chezmoi.update.plist
```

## 🛠 トラブルシューティング

### zshがデフォルトシェルにならない場合

```bash
echo "$(which zsh)" | sudo tee -a /etc/shells
chsh -s "$(which zsh)"
```

### chezmoiの設定をリセットしたい場合

```bash
chezmoi purge  # 注意: すべての管理ファイルが削除されます
rm -rf ~/.local/share/chezmoi
```

## 📝 カスタマイズ

### 個人情報の設定

初回実行時に名前とメールアドレスを聞かれます。これらは以下のファイルに保存されます：
- `~/.config/chezmoi/chezmoi.toml`

### エディタの変更

```bash
chezmoi edit-config
# [edit] セクションの command を変更
```

## 🔗 参考リンク

- [chezmoi公式ドキュメント](https://www.chezmoi.io/)
- [Homebrew](https://brew.sh/)
- [Aqua](https://aquaproj.github.io/)