# .zprofile

# OSの種類を判別し、パスを設定
if [ "$(uname)" = "Darwin" ]; then
    # macOSの場合
    export PATH="/opt/homebrew/bin:$PATH"
elif [ "$(uname)" = "Linux" ]; then
    # Linux（WSLも含む）の場合
    if [ -d "/home/linuxbrew/.linuxbrew/bin" ]; then
        export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
    elif [ -d "$HOME/.linuxbrew/bin" ]; then
        export PATH="$HOME/.linuxbrew/bin:$PATH"
    fi
fi