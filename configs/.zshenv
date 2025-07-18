
export XDG_DATA_HOME=$HOME/.local/share/
export XDG_CONFIG_HOME=$HOME/.config/
export XDG_STATE_HOME=$HOME/.local/state/
export XDG_CACHE_HOME=$HOME/.cache/

# Aquaのパスを追加
export PATH="${AQUA_ROOT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/aquaproj-aqua}/bin:$PATH"

