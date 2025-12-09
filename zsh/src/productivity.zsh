# =================================================================
# 🚀 Cockpit Productivity Module
# =================================================================

## 📝 Daily Report (AI Powered)
function daily() {
    echo "📝 Generating Daily Report..."
    
    # 今日の日付
    local today=$(date "+%Y-%m-%d")
    local report_file="$HOME/PARA/0_Inbox/Daily_${today}.md"
    
    # 1. 情報を収集 (Git Log)
    local git_log=""
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git_log=$(git log --since="6am" --pretty=format:"- %s" 2>/dev/null)
    fi
    
    # 情報がなければ終了
    if [ -z "$git_log" ]; then
        echo "🤔 No commits found today. Skipping AI summary."
        return
    fi
    
    echo "🤖 Asking AI to summarize..."
    
    # 2. AIに投げるプロンプト
    local prompt="以下のGitコミットログから、今日の業務日報(Markdown)を作成してください。
    - 簡潔な箇条書きで
    - 'やったこと' と '技術的な学び' に分けて
    
    --- Log ---
    $git_log"
    
    # ask関数 (ai.zsh) を利用
    local summary=$(ask "$prompt")
    
    # 3. 保存
    echo "# 📅 Daily Report: $today" > "$report_file"
    echo "" >> "$report_file"
    echo "$summary" >> "$report_file"
    
    echo "✅ Report saved to: $report_file"
    code "$report_file"
}

## 📂 Jump to Project
function p() {
    local n=$(ls "$HOME/PARA/1_Projects" 2>/dev/null | fzf --prompt="📂 Jump > " --height=40% --layout=reverse)
    [ -n "$n" ] && cd "$HOME/PARA/1_Projects/$n" && { command -v eza >/dev/null && eza --icons || ls; }
}

## 📝 Quick Capture (Log)
function log() {
    local msg="$*"
    [ -z "$msg" ] && echo "Usage: log 'msg'" && return 1
    local ts=$(date '+%H:%M')
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        # Gitプロジェクト内ならプロジェクトのログへ
        local root=$(git rev-parse --show-toplevel)
        mkdir -p "$root/docs"
        echo "- [$ts] $msg" >> "$root/docs/DEV_LOG.md"
        echo "📝 Logged to project (docs/DEV_LOG.md)."
    else
        # それ以外ならInboxへ
        echo "- [$ts] $msg" >> "$HOME/PARA/0_Inbox/quick_notes.md"
        echo "📝 Logged to Inbox."
    fi
}

## 🏥 Health Check (Project Audit)
function audit() {
    echo "🏥 Running Cockpit Health Check..."
    
    # 1. Git Status
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo ""
        echo "📊 --- Git Status ---"
        git status -s
    fi
    
    # 2. Config Check
    echo ""
    echo "⚙️  --- Configuration ---"
    if [ -f ".vscode/settings.json" ]; then
        echo "✅ VS Code Settings found."
    else
        echo "⚠️  No .vscode/settings.json found. (Run 'sync' to fix)"
    fi
    
    # 3. Extension Check
    if [ -f ".vscode/extensions.json" ]; then
        echo ""
        echo "🧩 --- Extensions Check ---"
        
        # 推奨リストを取得 (grepでIDを抽出)
        local rec_ids=$(grep -o '"[a-zA-Z0-9\.-]*\.[a-zA-Z0-9\.-]*"' .vscode/extensions.json | tr -d '"')
        
        # インストール済みリストを取得
        local installed_ids=$(code --list-extensions 2>/dev/null)
        
        # 照合ループ
        echo "$rec_ids" | while read -r id; do
            if [ -n "$id" ]; then
                if echo "$installed_ids" | grep -qi "$id"; then
                    echo "✅ Installed: $id"
                else
                    echo "❌ MISSING:   $id  (Install this!)"
                fi
            fi
        done
    fi
    
    echo ""
    echo "✅ Audit complete."
}

# Aliases
alias l="log"
alias b="briefing"
alias check="audit"
alias done="daily" # finish work alias
