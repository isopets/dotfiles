# =================================================================
# 🚀 My Dotfiles .zshrc (Stable Loader)
# =================================================================

# 1. 秘密情報の読み込み
if [ -f "$HOME/dotfiles/zsh/.zsh_secrets" ]; then
    source "$HOME/dotfiles/zsh/.zsh_secrets"
fi

# 2. 設定ディレクトリ定義
ZSH_CONFIG_DIR="$HOME/dotfiles/zsh/config"

# 3. 拡張機能の自動同期 (1日1回)
VSCODE_SYNC="$HOME/dotfiles/vscode/sync_extensions.sh"
LAST_SYNC="$HOME/.vscode_last_sync"
NOW=$(date +%s)

if [ -f "$LAST_SYNC" ]; then
    LAST=$(cat "$LAST_SYNC")
else
    LAST=0
fi

if [ $((NOW - LAST)) -gt 86400 ]; then
    if [ -x "$VSCODE_SYNC" ]; then
        nohup "$VSCODE_SYNC" >/dev/null 2>&1 &!
        echo "$NOW" > "$LAST_SYNC"
    fi
fi

# 4. 設定ファイルの読み込み
if [ -d "$ZSH_CONFIG_DIR" ]; then
    for f in "$ZSH_CONFIG_DIR"/*.zsh; do
        [ -r "$f" ] && source "$f"
    done
fi

# 5. 起動時チェック
if command -v git &> /dev/null; then
    if [[ -n $(git -C "$HOME/dotfiles" status --porcelain 2>/dev/null) ]]; then
        echo "🚨 Dotfiles Uncommitted Changes!"
    fi
fi

# 管理外プロファイルチェック
CHECK_SCRIPT="$HOME/dotfiles/scripts/check_unmanaged_profiles.sh"
if [ -x "$CHECK_SCRIPT" ]; then
    "$CHECK_SCRIPT"
fi

# 6. 今日のヒント
if command -v show-tip &> /dev/null; then
    show-tip
fi
