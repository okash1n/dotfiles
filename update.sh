#!/usr/bin/env bash
set -e

# スクリプト自身のディレクトリを確実に格納
SCRIPT_DIR=$(cd $(dirname $0); pwd)

# cronや非インタラクティブシェルから実行された場合のPATH設定
# TTYが割り当てられていない、またはPATHが最小限の場合
if [ ! -t 0 ] || [ -z "$PS1" ] || [[ "$PATH" != *"/opt/homebrew"* && "$PATH" != *"/usr/local/bin"* ]]; then
    # Homebrewのパスを追加 (Intel/Apple Silicon両対応)
    if [ -f "/opt/homebrew/bin/brew" ]; then
        # Apple Silicon Mac
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/usr/local/bin/brew" ]; then
        # Intel Mac
        eval "$(/usr/local/bin/brew shellenv)"
    elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        # Linux
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    
    # 基本的なPATHを確保
    export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
fi

# 色付き出力用の関数
print_section() {
    echo -e "\n\033[1;34m=== $1 ===\033[0m"
}

print_success() {
    echo -e "\033[0;32m✓ $1\033[0m"
}

print_error() {
    echo -e "\033[0;31m✗ $1\033[0m" >&2
}

print_info() {
    echo -e "\033[0;36mℹ $1\033[0m"
}

# Homebrew自体とパッケージの更新
update_homebrew_packages() {
    print_section "Updating Homebrew and Packages"
    
    if command -v brew >/dev/null 2>&1; then
        # Homebrew自体の更新
        print_info "Updating Homebrew..."
        if brew update; then
            print_success "Homebrew updated successfully"
        else
            print_error "Failed to update Homebrew"
            return 1
        fi
        
        # インストール済みパッケージの更新
        print_info "Upgrading Homebrew packages..."
        if brew upgrade; then
            print_success "Homebrew packages upgraded successfully"
        else
            print_error "Failed to upgrade Homebrew packages"
            return 1
        fi
        
        # 古いバージョンのクリーンアップ（オプション）
        print_info "Cleaning up old versions..."
        brew cleanup
        print_success "Cleanup completed"
    else
        print_error "Homebrew is not installed or not in PATH"
        return 1
    fi
}

# NPMグローバルパッケージの更新
update_npm_packages() {
    print_section "Updating NPM Global Packages"
    
    print_info "Updating NPM global packages..."
    if npm update -g; then
        print_success "NPM global packages updated successfully"
    else
        print_error "Failed to update NPM global packages"
        return 1
    fi
}

# Homebrew設定の更新
update_homebrew() {
    print_section "Backing up Homebrew Configuration"
    
    if command -v brew >/dev/null 2>&1; then
        echo "Updating .Brewfile from current Homebrew packages..."
        brew bundle dump --force --global --describe
        print_success "Homebrew configuration updated successfully."
    else
        print_error "Homebrew is not installed or not in PATH"
        return 1
    fi
}

# NPMグローバルパッケージの更新
update_npm_global() {
    print_section "Backing up NPM Global Packages"
    
    # 設定
    PACKAGE_JSON_PATH="$HOME/dotfiles/npm/package.json"
    BACKUP_DIR="$HOME/dotfiles/npm"
    MAX_BACKUPS=5
    
    # 現在の日時を取得 (YYYYMMDDhhmm形式)
    TIMESTAMP=$(date +"%Y%m%d%H%M")
    
    # package.jsonが存在しない場合は作成
    if [ ! -f "$PACKAGE_JSON_PATH" ]; then
        echo "Creating new package.json..."
        echo '{"dependencies": {}}' > "$PACKAGE_JSON_PATH"
    fi
    
    # 現在インストールされているグローバルパッケージを取得
    echo "Fetching current global packages..."
    CURRENT_PACKAGES=$(npm list -g --depth=0 --json 2>/dev/null | jq -r '.dependencies | to_entries | map("\"\(.key)\": \"\(.value.version)\"") | join(",")')
    
    # 現在のpackage.jsonの内容を取得
    EXISTING_PACKAGES=$(jq -r '.dependencies | to_entries | map("\"\(.key)\": \"\(.value)\"") | join(",")' "$PACKAGE_JSON_PATH" 2>/dev/null || echo "")
    
    # 差分をチェック
    if [ "$CURRENT_PACKAGES" != "$EXISTING_PACKAGES" ]; then
        echo "Differences found. Creating backup..."
        
        # バックアップを作成
        cp "$PACKAGE_JSON_PATH" "${PACKAGE_JSON_PATH}.${TIMESTAMP}"
        print_success "Backup created: ${PACKAGE_JSON_PATH}.${TIMESTAMP}"
        
        # 古いバックアップを削除（5世代まで保持）
        BACKUPS=($(ls -t "${PACKAGE_JSON_PATH}".* 2>/dev/null | grep -E '\.[0-9]{12}$'))
        if [ ${#BACKUPS[@]} -gt $MAX_BACKUPS ]; then
            echo "Removing old backups..."
            for ((i=$MAX_BACKUPS; i<${#BACKUPS[@]}; i++)); do
                rm "${BACKUPS[$i]}"
                echo "Removed: ${BACKUPS[$i]}"
            done
        fi
        
        # package.jsonを更新
        echo "Updating package.json..."
        cat > "$PACKAGE_JSON_PATH" <<EOF
{
  "name": "global-packages",
  "version": "1.0.0",
  "description": "NPM global packages backup",
  "dependencies": {
    $CURRENT_PACKAGES
  }
}
EOF
        
        print_success "NPM package.json updated successfully!"
        echo "Current packages:"
        jq '.dependencies' "$PACKAGE_JSON_PATH"
    else
        print_success "No differences found in NPM packages. No backup needed."
    fi
}

# メイン処理
main() {
    echo -e "\033[0;33m$(date '+%Y-%m-%d %H:%M:%S')\033[0m"
    echo "Starting system update and dotfiles backup process..."
    
    # エラーが発生しても続行するようにset -eを一時的に無効化
    set +e
    
    # 1. Homebrewとパッケージの更新
    update_homebrew_packages
    BREW_UPDATE_RESULT=$?
    
    # 2. NPMグローバルパッケージの更新
    update_npm_packages
    NPM_UPDATE_RESULT=$?
    
    # 3. Homebrew設定のバックアップ
    update_homebrew
    BREW_BACKUP_RESULT=$?
    
    # 4. NPMグローバルパッケージのバックアップ
    update_npm_global
    NPM_BACKUP_RESULT=$?
    
    # 5. 新しく追加されたdotfilesのシンボリックリンク作成
    link_new_dotfiles
    LINK_RESULT=$?
    
    # set -eを再度有効化
    set -e
    
    # 結果のサマリー
    print_section "Update Summary"
    
    if [ $BREW_UPDATE_RESULT -eq 0 ]; then
        print_success "Homebrew packages: Updated"
    else
        print_error "Homebrew packages: Update failed"
    fi
    
    if [ $NPM_UPDATE_RESULT -eq 0 ]; then
        print_success "NPM global packages: Updated"
    else
        print_error "NPM global packages: Update failed"
    fi
    
    if [ $BREW_BACKUP_RESULT -eq 0 ]; then
        print_success "Homebrew configuration: Backed up"
    else
        print_error "Homebrew configuration: Backup failed"
    fi
    
    if [ $NPM_BACKUP_RESULT -eq 0 ]; then
        print_success "NPM package.json: Backed up"
    else
        print_error "NPM package.json: Backup failed"
    fi
    
    if [ $LINK_RESULT -eq 0 ]; then
        print_success "Dotfile symlinks: Checked/Created"
    else
        print_error "Dotfile symlinks: Failed"
    fi
    
    # いずれかが失敗した場合は非ゼロで終了
    if [ $BREW_UPDATE_RESULT -ne 0 ] || [ $NPM_UPDATE_RESULT -ne 0 ] || 
       [ $BREW_BACKUP_RESULT -ne 0 ] || [ $NPM_BACKUP_RESULT -ne 0 ] ||
       [ $LINK_RESULT -ne 0 ]; then
        print_error "Some operations failed. Check the output above."
        exit 1
    fi
    
    print_success "All operations completed successfully!"
}

# 新たに追加されたdotfilesのシンボリックリンクを作成
link_new_dotfiles() {
    print_section "Checking for New Dotfiles"
    
    CONFIG_DIR="$SCRIPT_DIR/configs"
    local new_files_found=false
    local linked_count=0
    
    # shopt -s nullglob を使用してグロブが展開されない場合の問題を回避
    shopt -s nullglob
    
    # configsディレクトリ内のすべてのファイル/ディレクトリを処理
    for item in "$CONFIG_DIR"/* "$CONFIG_DIR"/.*; do
        # . と .. はスキップ
        [ "$(basename "$item")" == "." ] || [ "$(basename "$item")" == ".." ] && continue
        
        # ファイルまたはディレクトリが存在するかチェック
        [ ! -e "$item" ] && continue
        
        # ターゲットのパス
        TARGET="$HOME/$(basename "$item")"
        
        # シンボリックリンクが存在しない場合のみ作成
        if [ ! -L "$TARGET" ]; then
            # 既存のファイル/ディレクトリがある場合は警告
            if [ -e "$TARGET" ]; then
                print_info "Found existing non-symlink: $TARGET"
                print_info "Creating backup: ${TARGET}.backup"
                mv "$TARGET" "${TARGET}.backup"
            fi
            
            # シンボリックリンクを作成
            ln -snf "$item" "$TARGET"
            print_success "Created symlink: $(basename "$item") → $TARGET"
            new_files_found=true
            ((linked_count++))
        fi
    done
    
    if [ "$new_files_found" = true ]; then
        print_success "Created $linked_count new symbolic link(s)"
    else
        print_info "No new dotfiles found to link"
    fi
}

# スクリプト実行
main