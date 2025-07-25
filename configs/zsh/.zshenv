
# XDG Base Directory
export XDG_DATA_HOME=$HOME/.local/share/
export XDG_CONFIG_HOME=$HOME/.config/
export XDG_STATE_HOME=$HOME/.local/state/
export XDG_CACHE_HOME=$HOME/.cache/

# Zsh configuration directory
## /etc/zshenv or /etc/zsh/zshenv

# Claude Code
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"

# Aqua
export AQUA_GLOBAL_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/aqua/aqua.yaml"
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"

# Homebrew Bundle
export HOMEBREW_BUNDLE_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/homebrew/Brewfile"

# NPM configuration for XDG compliance
export NPM_CONFIG_USERCONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/npm/npmrc"
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/npm/bin:$PATH"

