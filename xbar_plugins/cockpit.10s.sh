#!/bin/bash

# --- Configuration ---
LOG_FILE="/tmp/cockpit_nix.log"
LOCK_FILE="/tmp/cockpit_nix.lock"

# --- Status Check ---
if [ -f "$LOCK_FILE" ]; then
    # 実行中
    echo "🔄 Cockpit | color=orange"
    echo "---"
    echo "🚀 Updating... | color=orange"
else
    # 待機中
    # 最後のログが成功か失敗かでアイコンを変える
    if grep -q "✅ Success" "$LOG_FILE" 2>/dev/null; then
        echo "✅ Cockpit | color=white"
    elif grep -q "❌ Failed" "$LOG_FILE" 2>/dev/null; then
        echo "⚠️ Cockpit | color=red"
    else
        echo "✈️ Cockpit | color=white"
    fi
    echo "---"
    echo "Idle"
fi

# --- Menu Actions ---
echo "---"
echo "📄 View Log | shell=open param1='-a' param2='Console' param3='$LOG_FILE'"
echo "🛠️ Run Update | shell=zsh param1='-c' param2='source ~/dotfiles/zsh/src/nix.zsh; nix-up' terminal=false refresh=true"
echo "♻️ Refresh Menu | refresh=true"
