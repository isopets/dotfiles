# --- 20_life.zsh : Logging & Life (AI Powered) ---

# 📝 Daily Report (AI Powered)
function daily() {
    echo "📝 Generating Daily Report..."
    local today=$(date "+%Y-%m-%d")
    local report_file="$HOME/PARA/0_Inbox/Daily/${today}.md"
    mkdir -p "$(dirname "$report_file")"
    
    if [ ! -f "$report_file" ]; then
        echo "# 📅 Daily Report: $today" > "$report_file"
        echo "" >> "$report_file"
        
        # Gitログの収集
        local git_log=""
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
            git_log=$(git log --since="6am" --pretty=format:"- %s" 2>/dev/null)
        fi

        if [ -n "$git_log" ]; then
            echo "🤖 Asking AI to summarize..."
            local prompt="以下のGitコミットログから、今日の業務日報(Markdown)を作成してください。箇条書きで簡潔に。: \n $git_log"
            # AIが使えるなら要約、使えなければ生ログ
            if [ -f "$HOME/dotfiles/scripts/ask_ai.py" ]; then
                ask "$prompt" >> "$report_file"
            else
                echo "## 🤖 Auto Log" >> "$report_file"
                echo "$git_log" >> "$report_file"
            fi
        else
            echo "## 📝 Log" >> "$report_file"
        fi
    fi
    copen "$report_file"
}
alias done="daily"

# 📝 Quick Capture
function log() {
    local m="$*"; [ -z "$m" ] && return 1
    echo "- $(date +%H:%M) $m" >> "$HOME/PARA/0_Inbox/quick_notes.md"
    echo "📝 Logged."
}
alias l="log"

# 📌 Remember URL
function remember() {
    local u=$(pbpaste); [[ "$u" != http* ]] && echo "⚠️ No URL" && return 1
    echo "$u" >> ".cockpit_urls"; echo "📌 Saved: $u"
}
alias rem="remember"

# 🏥 Health Check (Restored)
function audit() {
    echo "🏥 Cockpit Health Check..."
    echo "---------------------------"
    echo -n "Nix:      "; command -v nix >/dev/null && echo "✅" || echo "❌"
    echo -n "Starship: "; command -v starship >/dev/null && echo "✅" || echo "❌"
    echo -n "Gum:      "; command -v gum >/dev/null && echo "✅" || echo "❌"
    
    if [ -f ".vscode/settings.json" ]; then
        echo "✅ VS Code Settings found."
    fi
    echo "---------------------------"
    echo "Done."
}
alias check="audit"
