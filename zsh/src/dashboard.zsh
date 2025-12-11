# =================================================================
# 🚀 Cockpit Dashboard (Startup Briefing)
# [AI_NOTE]
# ターミナル起動時に実行。
# 1. 挨拶 & 健康チェック
# 2. Inboxの未処理件数
# 3. 最近のプロジェクトへのショートカット
# =================================================================

function cockpit-dashboard() {
    # 画面クリア
    clear

    # --- 1. Header & Health ---
    local hour=$(date +%H)
    local greeting=""
    local icon=""
    
    if [ $hour -lt 12 ]; then greeting="Good Morning"; icon="🌅"
    elif [ $hour -lt 18 ]; then greeting="Good Afternoon"; icon="☀️"
    else greeting="Good Evening"; icon="🌙"
    fi

    # ランダムな健康Tips
    local tips=(
        "💧 Hydration Check: Have you had water recently?"
        "👀 20-20-20 Rule: Look away from screen every 20 mins."
        "🧘 Posture Check: Shoulders down, back straight."
        "🌬️  Deep Breath: Inhale for 4s, hold for 7s, exhale for 8s."
        "🚶 Stand Up: Take a short walk if you've been sitting."
    )
    local tip=${tips[$RANDOM % ${#tips[@]}]}

    echo ""
    echo -e "\033[1;36m$icon  $greeting, $USER.\033[0m"
    echo -e "\033[0;90m   $tip\033[0m"
    echo ""

    # --- 2. Inbox Status ---
    local inbox_count=$(ls ~/PARA/0_Inbox 2>/dev/null | wc -l | xargs)
    if [ "$inbox_count" -gt 0 ]; then
        echo -e "📥 \033[1;33mYou have $inbox_count items in Inbox.\033[0m (Type 'cd inbox' to clean)"
    else
        echo -e "✨ \033[1;32mInbox Zero. Clear mind.\033[0m"
    fi
    echo ""

    # --- 3. Recent Projects (Context Recall) ---
    # PARA/1_Projects 内で最近更新されたフォルダトップ3を取得
    echo "🚀 Recent Missions:"
    
    # ls -t で更新順にソートして表示 (ディレクトリのみ)
    # 実際には gum choose で選ばせたいが、起動時は表示だけに留める（選択を強制しない）
    local recents=$(ls -dt ~/PARA/1_Projects/*/ 2>/dev/null | head -n 3)
    
    if [ -n "$recents" ]; then
        basename -a $recents | while read line; do
            echo "   🔹 $line"
        done
        echo ""
        echo -e "\033[0;90m👉 Type 'w' (work) to resume.\033[0m"
    else
        echo "   (No active projects)"
        echo -e "\033[0;90m👉 Type 'mkproj' to start a new mission.\033[0m"
    fi
    echo ""
}

# --- Auto Start ---
# Zsh起動時にダッシュボードを表示
# (ただし、VSCodeの統合ターミナルなどで毎回出るとウザい場合もあるので、SHLVL判定などを入れても良い)
# ここではシンプルに「対話型シェルなら表示」とする。
if [[ -o interactive ]]; then
    cockpit-dashboard
fi

# --- Alias ---
# 手動で呼び出す用
alias home="cockpit-dashboard"
