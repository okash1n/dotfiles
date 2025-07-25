# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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