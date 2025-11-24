#!/bin/zsh

# --- 拡張機能の自動同期 (1日1回) ---
VSCODE_SYNC="$HOME/dotfiles/vscode/sync_extensions.sh"
LAST_SYNC="$HOME/.vscode_last_sync"
NOW=$(date +%s)

if [ -f "$LAST_SYNC" ]; then
    LAST=$(cat "$LAST_SYNC")
else
    LAST=0
fi

# 24時間(86400秒)経過チェック
if [ $((NOW - LAST)) -gt 86400 ]; then
    if [ -x "$VSCODE_SYNC" ]; then
        # バックグラウンドで実行
        "$VSCODE_SYNC" >/dev/null 2>&1 &
        echo "$NOW" > "$LAST_SYNC"
    fi
fi

# --- 管理外プロファイルの警告 ---
CHECK_SCRIPT="$HOME/dotfiles/scripts/check_unmanaged_profiles.sh"
if [ -x "$CHECK_SCRIPT" ]; then
    "$CHECK_SCRIPT"
fi

# --- 今日のヒント表示 ---
# (関数が読み込まれた後に実行される必要があるため、ここでは呼び出さないか、zshrc側で呼ぶ)
