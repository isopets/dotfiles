# =================================================================
# 🚀 My Dotfiles .zshrc (Loader)
# =================================================================

# 1. 秘密情報の読み込み (APIキーなど)
if [ -f "$HOME/dotfiles/zsh/.zsh_secrets" ]; then
    source "$HOME/dotfiles/zsh/.zsh_secrets"
fi

# 2. 設定ディレクトリの定義
ZSH_CONFIG_DIR="$HOME/dotfiles/zsh/config"

# 3. 拡張機能の自動同期 (1日1回 バックグラウンド実行)
VSCODE_SYNC_SCRIPT="$HOME/dotfiles/vscode/sync_extensions.sh"
LAST_SYNC_FILE="$HOME/.vscode_last_sync"

if [ -f "$LAST_SYNC_FILE" ]; then
    # 最終実行から24時間(86400秒)経過しているか？
    if [ $(( $(date +%s) - $(cat "$LAST_SYNC_FILE") )) -gt 86400 ]; then
        nohup "$VSCODE_SYNC_SCRIPT" > /dev/null 2>&1 &!
        date +%s > "$LAST_SYNC_FILE"
    fi
else
    # 初回実行
    nohup "$VSCODE_SYNC_SCRIPT" > /dev/null 2>&1 &!
    date +%s > "$LAST_SYNC_FILE"
fi

# 4. 設定ファイルの読み込み (ここが重要)
# 番号順 (01->02->03->04) に読み込むことで依存関係を解決
if [ -d "$ZSH_CONFIG_DIR" ]; then
    for file in "$ZSH_CONFIG_DIR"/*.zsh; do
        source "$file"
    done
fi

# 5. 未コミットの警告
if command -v git &> /dev/null; then
    if [[ $(git -C "$HOME/dotfiles" status --porcelain 2>/dev/null) ]]; then
        echo "🚨 Dotfiles Uncommitted Changes!"
    fi
fi

# 6. 管理外プロファイルの警告
if [ -x "$HOME/dotfiles/scripts/check_unmanaged_profiles.sh" ]; then
    "$HOME/dotfiles/scripts/check_unmanaged_profiles.sh"
fi

# 7. 今日のヒント (04_functions.zshで定義)
if command -v show-tip &> /dev/null; then
    show-tip
fi
