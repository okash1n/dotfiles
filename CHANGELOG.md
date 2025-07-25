# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.8.5] - 2025-07-25

### Added
- [chezmoi](https://www.chezmoi.io/)によるdotfiles管理システムの導入
  - `.chezmoi.toml.tmpl`: chezmoi設定テンプレート
  - `.chezmoiignore`: chezmoi管理から除外するファイルの定義
  - `run_once_`スクリプト: 初回セットアップ時の自動実行
  - `run_onchange_`スクリプト: ファイル変更時の自動実行
- 自動更新機能
  - macOS launchdによる毎日12:00の自動更新
  - Brewfile/package.json変更時の自動パッケージインストール
- chezmoiをBrewfileに追加

### Changed
- dotfilesのディレクトリ構造をchezmoi規約に準拠
  - `configs/` → `dot_config/`
  - 隠しファイルの命名規則（`.zshrc` → `dot_zshrc`）
- Brewfileの配置を標準位置に変更
  - `~/.config/homebrew/Brewfile` → `~/.Brewfile`
  - `HOMEBREW_BUNDLE_FILE`環境変数を削除
  - `brew bundle --global`コマンドのサポート
- セットアップフローの簡素化
  - `init.sh`: Homebrewとchezmoiのセットアップに特化
  - `update.sh`: chezmoiの機能に置き換え（非推奨）
- XDGディレクトリパスの末尾スラッシュを削除（ダブルスラッシュ問題の修正）

### Fixed
- post-apply hookの削除（新規zshセッション起動の問題を修正）
- run_onceスクリプトの番号付けを連番に修正

### Documentation
- READMEをchezmoi中心の内容に全面改訂
  - セットアップ手順の更新
  - chezmoiコマンドの使い方
  - トラブルシューティングセクション

## [0.8.0] - 2025-07-25

### Added
- XDG Base Directory仕様への全面的な対応
  - `LESSHISTFILE`を`$XDG_STATE_HOME/less/history`に設定
  - Vim設定ファイル（`configs/vim/vimrc`）を追加、`.viminfo`をXDG準拠に
  - ZSHのキャッシュと履歴をXDG準拠のパスに設定
  - `XDG_RUNTIME_DIR`の設定を追加（macOS用に一時ディレクトリを使用）
- 環境変数設定の拡充
  - `.zshenv`にLESS、NPM、XDG_RUNTIME_DIRの設定を追加
  - `.zshrc`にZSHのcompletion cache、history、compdumpの設定を追加

### Changed
- `init.sh`のNPM設定処理を改善
  - XDGディレクトリの作成処理を追加
  - NPM設定のシンボリックリンク作成処理を追加

### Removed
- ホームディレクトリの不要なファイル・ディレクトリを削除
  - `.configback`（空のバックアップディレクトリ）
  - `.zcompcache`（古いZSHキャッシュ）
  - `.zsh_sessions`（ZSHセッション履歴）
  - `.terminfo`（XDGに移行済み）
  - `.lesshst`、`.viminfo`、`.zcompdump*`、`.zsh_history`（XDGに移行済み）

## [0.7.0] - 2025-07-25

### Added
- NPMをXDG Base Directory準拠で管理する設定を追加
  - `configs/npm/npmrc`: NPM設定ファイル（キャッシュ、グローバルパッケージ、ログパスを設定）
  - 環境変数`NPM_CONFIG_USERCONFIG`を`.zshenv`に追加
  - NPMグローバルbinディレクトリをPATHに追加

### Changed
- dotfilesディレクトリ構造を再編成
  - 設定ファイルを隠しディレクトリから整理された構造に移動
  - `configs/.config/` → `configs/`への移動（gh, ghostty, git, karabiner, raycast等）
  - `configs/.aqua/` → `configs/aqua/`
  - `configs/.Brewfile` → `configs/homebrew/Brewfile`
- NPMグローバルパッケージの管理場所を変更
  - `npm/package.json` → `configs/npm/global-packages.json`
  - `update.sh`のパスを新しい構造に合わせて更新
- .gitignoreを更新
  - `.zsh_history`を追加（すでに追跡されていたファイルも削除）
  - npmバックアップファイルのパスを更新

### Removed
- 一時的なClaudeファイルとキャッシュを削除
- 空になった`npm/`ディレクトリを削除
- `~/.npm`ディレクトリ（XDG準拠のパスに移行）

## [0.6.1] - 2025-07-25

### Changed
- .gitignoreファイルを現在のディレクトリ構成に合わせて更新
  - Claudeの一時ファイルやキャッシュを適切に除外
  - Raycast extensionsのnode_modulesを除外
  - npmバックアップファイルを除外
  - 各種ツールの自動生成ファイルを除外

## [0.6.0] - 2025-07-23

### Added
- 基本的なdotfiles管理機能
- 環境構築自動化スクリプト（`init.sh`）
  - Rosetta自動インストール（Apple Silicon Mac）
  - Homebrew自動インストール（macOS/Linux対応）
  - dotfilesのシンボリックリンク作成
  - cronジョブによる3時間ごとの自動更新
- 更新・バックアップスクリプト（`update.sh`）
  - 実行日時をログの最初に表示（黄色のタイムスタンプ）
  - Homebrewパッケージの自動更新
  - NPMグローバルパッケージの自動更新
  - 設定ファイルの自動バックアップ（5世代管理）
  - 新規dotfilesの自動検出・リンク機能
  - カラフルなログ出力（成功/エラー/情報の色分け）
- パッケージ管理
  - Homebrewによるシステムパッケージ管理（`.Brewfile`）
  - Aqua（宣言的CLIバージョン管理）
  - NPMグローバルパッケージ管理（`package.json`）
- 開発環境設定
  - Zsh環境設定（Powerlevel10k統合）
  - Visual Studio Code拡張機能管理
  - Ghosttyターミナルエミュレータサポート

### Features
- クロスプラットフォーム対応（macOS Intel/Apple Silicon、Linux）
- 非破壊的な設定管理（既存ファイルを`.backup`として保存）
- 非インタラクティブ環境でのPATH自動設定
- エラーハンドリングと継続実行