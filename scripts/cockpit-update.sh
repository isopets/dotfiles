#!/bin/bash
# Cockpit System Update Wrapper

# パスを確実に通す
export PATH="/run/current-system/sw/bin:$HOME/.nix-profile/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
DIR="$HOME/dotfiles"

# nhコマンドがなければ終了
if ! command -v nh &> /dev/null; then
    echo "❌ Error: 'nh' command not found."
    exit 1
fi

# システム更新実行 (ここが核心)
echo "🔄 Running nh darwin switch..."
nh darwin switch "$DIR"
