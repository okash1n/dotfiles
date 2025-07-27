#!/usr/bin/env bash
set -e

# 最小限のdotfiles更新スクリプト (v0.9.1)
# このスクリプトはdotfilesの更新とパッケージの更新を行います

SCRIPT_DIR=$(cd $(dirname $0); pwd)

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

# Homebrewのパスを設定
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

# メイン処理
main() {
    echo -e "\033[0;33m$(date '+%Y-%m-%d %H:%M:%S')\033[0m"
    echo "Starting dotfiles and package update process..."
    
    # Homebrewのパスを設定
    setup_homebrew_path
    
    # 1. chezmoiでdotfilesを更新
    print_section "Updating dotfiles with chezmoi"
    if command -v chezmoi &> /dev/null; then
        print_info "Pulling latest changes and applying..."
        if chezmoi update --apply; then
            print_success "Dotfiles updated successfully"
        else
            print_error "Failed to update dotfiles"
        fi
    else
        print_error "chezmoi is not installed"
        echo "Please run init.sh first to install chezmoi"
        exit 1
    fi
    
    # 2. Homebrewパッケージの更新
    print_section "Updating Homebrew packages"
    if command -v brew &> /dev/null; then
        print_info "Updating Homebrew..."
        brew update
        
        print_info "Upgrading packages..."
        brew upgrade
        
        print_info "Cleaning up old versions..."
        brew cleanup
        
        print_success "Homebrew packages updated"
    else
        print_error "Homebrew is not installed"
    fi
    
    # 3. NPMグローバルパッケージの更新
    print_section "Updating NPM global packages"
    if command -v npm &> /dev/null; then
        print_info "Updating NPM packages..."
        npm update -g
        print_success "NPM packages updated"
    else
        print_error "npm is not installed"
    fi
    
    # 4. Aquaパッケージの更新
    if command -v aqua &> /dev/null; then
        print_section "Updating Aqua packages"
        if [ -f "$HOME/.config/aqua/aqua.yaml" ]; then
            print_info "Updating Aqua packages..."
            aqua update
            print_success "Aqua packages updated"
        else
            print_info "No aqua.yaml found, skipping Aqua update"
        fi
    fi
    
    print_section "Update Summary"
    print_success "All update operations completed!"
    echo ""
    echo "To see what changes were made to your dotfiles:"
    echo "  chezmoi diff"
    echo ""
    echo "To manually apply specific changes:"
    echo "  chezmoi apply <file>"
}

# スクリプト実行
main