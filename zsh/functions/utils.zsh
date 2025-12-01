# =================================================================
# 🛠️ Utility Functions (Brain & System)
# =================================================================

function sz() {
    echo "🔄 Re-spawning Shell Process..."
    exec zsh
}

function rules() {
    echo "📖 Opening Manual..."
    code ~/dotfiles/docs/WORKFLOW.md
}

function dot-doctor() {
    echo "🚑 Cockpit System Diagnosis..."
    local health=100
    if command -v fzf >/dev/null; then echo "  ✅ fzf found"; else echo "  ❌ fzf missing"; health=50; fi
    if command -v code >/dev/null; then echo "  ✅ code found"; else echo "  ❌ code missing"; health=50; fi
    
    if [ $health -eq 100 ]; then echo "✨ System Healthy."; else echo "⚠️ System Check Failed."; fi
}

# --- The Second Brain ---
function brain() {
    local brain_dir="$HOME/PARA/0_Inbox/Brain"
    mkdir -p "$brain_dir"

    # サブコマンド分岐
    if [ "$1" = "new" ]; then
        echo -n "🧠 Note Title: "; read title
        local safe_title=$(echo "$title" | tr ' ' '_')
        local file="$brain_dir/$(date +%Y%m%d)_${safe_title}.md"
        echo "# $title\n\n" > "$file"
        code "$file"
        return
    fi

    # 検索モード (fzf + bat preview)
    # ファイルの中身も検索対象にする (grep)
    local selected=$(grep -r "" "$brain_dir" 2>/dev/null | \
        fzf --delimiter : --with-nth 1,3 --preview 'bat --style=numbers --color=always {1} --highlight-line {2}' \
            --preview-window 'right:60%' \
            --prompt="🧠 Search Brain > " \
            --bind 'enter:execute(code {1})')
}

# --- 🧭 Contextual Guide (HUD) ---
function guide() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD: Contextual Guide"
    echo ""

    # 1. 現在地のコンテキスト分析
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        gum style --foreground 196 "🔥 You are inside a Project (Git Repo)"
        echo "Recommended Actions:"
        echo "  🚀 work        : Re-launch environment (VS Code + Assets)"
        echo "  🏁 done        : Finish work (Auto-Log & Commit)"
        echo "  💬 gcm         : Generate AI Commit Message"
        echo "  🕹️  lazygit     : Open Git Cockpit"
    else
        gum style --foreground 39 "🌍 You are in Global Space"
        echo "Recommended Actions:"
        echo "  ✨ mkproj      : Create new project (Intent-Driven)"
        echo "  🧠 brain       : Search Knowledge Base"
        echo "  📝 scratch     : Open temporary workspace"
        echo "  z <name>       : Teleport to project"
    fi

    echo ""
    gum style --foreground 244 "--- System Shortcuts ---"
    echo "  🔄 sz          : Reload Shell (Fix weirdness)"
    echo "  💊 dot-doctor  : Diagnose system health"
    echo "  🕰️  nix-history : Restore previous config"
    echo ""
}

# --- 🧭 Contextual Guide (HUD) ---
function guide() {
    echo ""
    gum style --foreground 214 --bold --border double --padding "0 2" "🧭 COCKPIT HUD: Contextual Guide"
    echo ""

    # 1. 現在地のコンテキスト分析
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        gum style --foreground 196 "🔥 You are inside a Project (Git Repo)"
        echo "Recommended Actions:"
        echo "  🚀 work        : Re-launch environment (VS Code + Assets)"
        echo "  🏁 done        : Finish work (Auto-Log & Commit)"
        echo "  💬 gcm         : Generate AI Commit Message"
        echo "  🕹️  lazygit     : Open Git Cockpit"
    else
        gum style --foreground 39 "🌍 You are in Global Space"
        echo "Recommended Actions:"
        echo "  ✨ mkproj      : Create new project (Intent-Driven)"
        echo "  🧠 brain       : Search Knowledge Base"
        echo "  📝 scratch     : Open temporary workspace"
        echo "  z <name>       : Teleport to project"
    fi

    echo ""
    # 修正点: ハイフンの代わりに安全な区切り線を使用し、-- で引数を保護
    gum style --foreground 244 -- "=== System Shortcuts ==="
    echo "  🔄 sz          : Reload Shell (Fix weirdness)"
    echo "  💊 dot-doctor  : Diagnose system health"
    echo "  🕰️  nix-history : Restore previous config"
    echo ""
}

# --- 💰 Cost Co-Pilot ---
function cost-check() {
    local log="$HOME/.cache/cockpit_api_usage.log"
    local cost_file="$HOME/dotfiles/config/api/api_costs.yml"

    if [ ! -f "$log" ]; then
        echo "💡 API usage log is empty."
        return 0
    fi
    
    # 価格情報をYAMLファイルから読み込む (yqを使用)
    local input_cost=$(yq '.gemini-2-flash.input' "$cost_file")
    local output_cost=$(yq '.gemini-2-flash.output' "$cost_file")
    
    local total_input_tokens=0
    local total_output_tokens=0

    # ログファイルを読み込み、トークン数を集計
    while read -r timestamp model total_tokens input_tokens; do
        if [ "$model" = "gemini-2-flash" ]; then
            total_input_tokens=$((total_input_tokens + input_tokens))
            local output_tokens=$((total_tokens - input_tokens))
            total_output_tokens=$((total_output_tokens + output_tokens))
        fi
    done < "$log"
    
    # コスト計算 (単位: ドルセント)
    # (トークン数 / 1,000,000) * 価格
    local final_cost_raw=$(echo "scale=4; ($total_input_tokens / 1000000 * $input_cost) + ($total_output_tokens / 1000000 * $output_cost)" | bc -l)
    
    # 最終的な表示
    gum style --foreground 220 "--- 💰 API Cost Report ---"
    gum style --foreground 150 "Input Tokens: $(($total_input_tokens / 1000))K"
    gum style --foreground 150 "Output Tokens: $(($total_output_tokens / 1000))K"
    gum style --foreground 46 --bold "Estimated Cost: \$$(printf "%.2f" "$final_cost_raw")"
    echo "---------------------------"
}

# 2. dashboard.zsh の更新 (devメニューの統合)
if command -v gsed &>/dev/null; then SED="gsed"; else SED="sed"; fi
$SED -i '/"📖 Manual"/i \            "💰 Cost Report    (cost-check)"' ~/dotfiles/zsh/functions/dashboard.zsh
$SED -i '/\*Manual\*\)/i \*Cost Report\*\) cost-check \;\;' ~/dotfiles/zsh/functions/dashboard.zsh

