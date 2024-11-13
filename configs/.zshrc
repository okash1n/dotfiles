function source {
  ensure_zcompiled $1
  builtin source $1
}
function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "Compiling $1"
    zcompile $1
  fi
}
ensure_zcompiled ~/.zshrc

CACHE_DIR=${XDG_CACHE_HOME:-$HOME/.cache}
SHELDON_CACHE="$CACHE_DIR/sheldon.zsh"
SHELDON_TOML="$HOME/.config/sheldon/plugins.toml"
if [[ ! -r "$SHELDON_CACHE" || "$SHELDON_TOML" -nt "$SHELDON_CACHE" ]]; then
  mkdir -p $CACHE_DIR
  sheldon source > $SHELDON_CACHE
fi
source "$SHELDON_CACHE"
unset CACHE_DIR SHELDON_CACHE SHELDON_TOML

zsh-defer unfunction source
