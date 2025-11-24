export LANG=ja_JP.UTF-8

# Homebrew Path
if [ -d "/opt/homebrew/bin" ]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

# Go Path
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
