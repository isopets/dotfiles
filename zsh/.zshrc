# =================================================================
# 🚀 My Dotfiles .zshrc (Loader)
# =================================================================

ZSH_CONFIG_DIR="$HOME/dotfiles/zsh/config"

# 拡張機能の自動同期チェック (1日1回)
VSCODE_SYNC_SCRIPT="$HOME/dotfiles/vscode/sync_extensions.sh"
LAST_SYNC_FILE="$HOME/.vscode_last_sync"

if [ -f "$LAST_SYNC_FILE" ]; then
    LAST_SYNC_TIME=$(cat "$LAST_SYNC_FILE")
    if [ $(( $(date +%s) - LAST_SYNC_TIME )) -gt 86400 ]; then
        nohup "$VSCODE_SYNC_SCRIPT" > /dev/null 2>&1 & 
        date +%s > "$LAST_SYNC_FILE"
        echo "⏳ VS Code拡張機能の自動同期を実行しました。"
    fi
else
    nohup "$VSCODE_SYNC_SCRIPT" > /dev/null 2>&1 &
    date +%s > "$LAST_SYNC_FILE"
fi

# 設定ファイルの読み込み
if [ -d "$ZSH_CONFIG_DIR" ]; then
    for file in "$ZSH_CONFIG_DIR"/*.zsh; do
        source "$file"
    done
fi

# 未コミットの変更チェック
if [[ $(git -C "$HOME/dotfiles" status --porcelain) ]]; then
    echo "🚨🚨🚨 Dotfilesの未コミットの変更があります！ 🚨🚨🚨"
fi
