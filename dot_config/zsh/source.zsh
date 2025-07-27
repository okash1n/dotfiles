


# aqua configuration
export AQUA_CONFIG="$HOME/.config/aqua/aqua.yaml"

# Ensure XDG directories are set
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# powerlevel10kのパスを動的に設定
if [ -f "/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
elif [ -f "/home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source /home/linuxbrew/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme
elif [ -f "$HOME/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme" ]; then
    source $HOME/.linuxbrew/share/powerlevel10k/powerlevel10k.zsh-theme
else
    echo "Warning: powerlevel10k theme not found"
fi

# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh.
[[ ! -f ${ZDOTDIR:-$HOME}/.p10k.zsh ]] || source ${ZDOTDIR:-$HOME}/.p10k.zsh
