# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.9.2] - 2025-07-27

### Added
- Ubuntu/Linux環境での完全サポート
  - ARM64アーキテクチャ対応（Ubuntu ARM仮想マシンでテスト済み）
  - Homebrew on Linuxの適切なパス設定（`/home/linuxbrew`と`$HOME/.linuxbrew`）
  - Linux環境でのpowerlevel10kテーマパスの動的検出
- 自動更新機能の改善
  - macOS: launchdを使用（セキュリティ制限を回避）
  - Linux: cronを使用（自動インストール対応: Ubuntu/RHEL系）
  - 毎日12:00にchezmoi updateを実行
  - Homebrewパスを自動検出して設定
- macOSターミナルの自動設定
  - Terminal.appにDracula Proテーマを自動適用
  - Hack Nerd Fontをデフォルトフォントに設定
  - Ghosttyには既に設定済み
  - ローカル環境でセットアップ後にGhosttyを自動起動

### Changed
- すべてのスクリプトでLinux用Homebrewパスを追加
  - `run_once_after_*.sh.tmpl`スクリプト群
  - `run_onchange_*.sh.tmpl`スクリプト群
  - `source.zsh`でのpowerlevel10kパス動的設定
- README.mdをLinux対応に更新
  - Linux環境での前提条件を追加
  - 自動更新機能のOS別説明を追加

### Fixed
- Linux環境でのlaunchctlエラーを修正
  - `run_once_01-setup-auto-update.sh.tmpl`でmacOS専用コマンドをスキップ
  - launchdベースの自動更新をmacOSのみに限定
- Linux環境での完全自動セットアップ実現
  - デフォルトシェルのzshへの自動変更（`/etc/shells`への追加と`chsh`実行）
  - GitHub CLI (gh)のビルド失敗時に公式バイナリを自動ダウンロード・インストール
  - zshのパス検出を改善して確実に起動
- 前提条件の自動確認・インストール
  - macOS: Xcode Command Line Toolsの自動確認（未インストールの場合はプロンプト表示）
  - Linux: build-essentialの自動インストール（Ubuntu/Debian、RHEL/CentOS対応）
- ARM64 Linux環境でのパッケージインストールエラーを修正
  - ボトル（ビルド済みバイナリ）が利用できないパッケージの処理を改善
  - xdg-ninjaをARM64 Linux環境で除外（依存関係の問題）
  - brew bundleのエラーをより寛容に処理
  - ghqのセグメンテーションフォルトに対する回避策を実装
  - Makefileでzshが見つからない場合のエラーハンドリングを改善
- スクリプト内のバージョン表記を削除
  - init.shからバージョン番号を削除（メンテナンス性向上）
- 不要なファイルを削除
  - init.sh.bak（古いバージョンのバックアップ）

## [0.9.0] - 2025-07-27

### Added
- 完全自動化された初期セットアップ
  - パスワード入力を最初の1回のみに統合（sudo認証）
  - Homebrewの非対話的インストール（`NONINTERACTIVE=1`）
  - GitHubのSSHホスト鍵を自動追加（known_hosts）
  - プライベートリポジトリのSSHクローン対応
- 初回実行時の最適化
  - run_onchangeスクリプトの初回スキップ機能（`.chezmoi_initialized`フラグ）
  - PATH設定の問題を回避
  - 実行順序の最適化によるsudoタイムアウト回避
- プライベートアセット管理機能
  - `ghq`を使用したプライベートリポジトリの自動クローン
  - VSCode拡張機能（dracula-pro.vsix）の自動インストール
- セットアップ完了後の自動zsh起動
  - `make init`実行後も自動的にzshセッションを開始
  - 設定済み環境がすぐに使用可能

### Changed
- `/etc/zshenv`のZDOTDIR設定を早期実行に変更
  - Brewパッケージインストール前に実行してsudoタイムアウトを防止
- chezmoiテンプレート変数を固定値に変更
  - 初回実行時のGit設定読み取りを削除
  - 個人リポジトリ用の固定値を使用
- エラーハンドリングの改善
  - makeからの実行を検出してexec zshの挙動を調整
  - エラートラップとexitステータスの明示化

### Fixed
- Brewfileの問題修正
  - 非推奨の`homebrew/bundle` tapを削除
  - 有料拡張機能のエラーを解消
  - jqパッケージを追加（NPMスクリプトで必要）
- run_onchangeスクリプトのPATH問題を修正
  - 各スクリプトで必要なPATH設定を追加
  - aqua設定ファイルの存在チェックを追加
  - PATH重複を防ぐチェック機能
- その他の修正
  - Raycast node_modulesシンボリックリンクを削除
  - LaunchAgentsディレクトリの自動作成
  - 状態管理ファイルをgitignoreに追加

### Documentation
- READMEを更新
  - v0.9.0の新機能を反映
  - 完全自動セットアップについての説明を追加
  - バージョンバッジを更新

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